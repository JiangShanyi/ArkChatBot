import http from '@ohos.net.http';

export interface ChatMessageDto {
  role: string;
  content: string;
}

export interface ChatRequest {
  messages: ChatMessageDto[];
}

export interface ChatResponse {
  reply: string;
}

export class ChatApi {
  private static readonly BASE_URL: string = 'http://192.168.12.24:3000/api/chat';

  static async send(messages: ChatMessageDto[]): Promise<string> {
    const request = http.createHttp();

    const body: ChatRequest = {
      messages: messages
    };

    try {
      const response = await request.request(ChatApi.BASE_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(body),
        connectTimeout: 10000,
        readTimeout: 60000
      });

      if (response.responseCode < 200 || response.responseCode >= 300) {
        throw new Error(`Server error: ${response.responseCode}`);
      }

      const resultText = response.result as string;
      const result = JSON.parse(resultText) as ChatResponse;

      return result.reply;
    } finally {
      request.destroy();
    }
  }
}