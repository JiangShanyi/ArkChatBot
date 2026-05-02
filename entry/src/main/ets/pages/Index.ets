import { ChatApi, ChatMessageDto } from '../api/ChatApi';

class ChatMessage {
  id: string;
  role: string;
  content: string;

  constructor(id: string, role: string, content: string) {
    this.id = id;
    this.role = role;
    this.content = content;
  }
}

@Entry
@Component
struct Index {
  private scroller: Scroller = new Scroller();

  @State inputText: string = '';
  @State isSending: boolean = false;
  @State messages: ChatMessage[] = [
    new ChatMessage('welcome', 'assistant', 'Hi, I am your ArkUI chatbot. Ask me anything.')
  ];

  private makeId(): string {
    return `${new Date().getTime()}_${Math.floor(Math.random() * 100000)}`;
  }

  private scrollToBottom(): void {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 80);
  }

  private toDtoList(): ChatMessageDto[] {
    return this.messages
      .filter((item: ChatMessage) => item.id !== 'typing')
      .map((item: ChatMessage): ChatMessageDto => {
        return {
          role: item.role,
          content: item.content
        };
      });
  }

  private async sendMessage(): Promise<void> {
    const text = this.inputText.trim();

    if (text.length === 0 || this.isSending) {
      return;
    }

    const userMessage = new ChatMessage(this.makeId(), 'user', text);
    const typingMessage = new ChatMessage('typing', 'assistant', 'Thinking...');

    this.inputText = '';
    this.isSending = true;
    this.messages = [
      ...this.messages,
      userMessage,
      typingMessage
    ];

    this.scrollToBottom();

    try {
      const reply = await ChatApi.send(this.toDtoList());

      const assistantMessage = new ChatMessage(this.makeId(), 'assistant', reply);

      this.messages = this.messages
        .filter((item: ChatMessage) => item.id !== 'typing')
        .concat(assistantMessage);
    } catch (err) {
      const errorMessage = new ChatMessage(
        this.makeId(),
        'assistant',
        'Sorry, I could not connect to the AI server. Please check the backend address and network permission.'
      );

      this.messages = this.messages
        .filter((item: ChatMessage) => item.id !== 'typing')
        .concat(errorMessage);
    } finally {
      this.isSending = false;
      this.scrollToBottom();
    }
  }

  @Builder
  Header() {
    Row() {
      Column() {
        Text('ArkChat')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182033')

        Text('HarmonyOS + ArkUI + LLM')
          .fontSize(13)
          .fontColor('#6B7280')
          .margin({ top: 4 })
      }
      .layoutWeight(1)

      Text(this.isSending ? 'Online' : 'Ready')
        .fontSize(12)
        .fontColor('#FFFFFF')
        .padding({
          left: 12,
          right: 12,
          top: 6,
          bottom: 6
        })
        .backgroundColor(this.isSending ? '#7C3AED' : '#2563EB')
        .borderRadius(16)
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20,
      top: 20,
      bottom: 12
    })
  }

  @Builder
  MessageBubble(item: ChatMessage) {
    Row() {
      if (item.role === 'assistant') {
        Text('AI')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width(34)
          .height(34)
          .textAlign(TextAlign.Center)
          .backgroundColor('#2563EB')
          .borderRadius(17)
          .margin({ right: 8 })
      }

      Column() {
        Text(item.content)
          .fontSize(15)
          .fontColor(item.role === 'user' ? '#FFFFFF' : '#111827')
          .lineHeight(22)
      }
      .padding({
        left: 14,
        right: 14,
        top: 10,
        bottom: 10
      })
      .backgroundColor(item.role === 'user' ? '#2563EB' : '#FFFFFF')
      .borderRadius(18)
      .constraintSize({
        maxWidth: '76%'
      })
      .shadow({
        radius: item.role === 'user' ? 8 : 12,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 4
      })

      if (item.role === 'user') {
        Text('Me')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width(34)
          .height(34)
          .textAlign(TextAlign.Center)
          .backgroundColor('#111827')
          .borderRadius(17)
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .justifyContent(item.role === 'user' ? FlexAlign.End : FlexAlign.Start)
    .padding({
      left: 16,
      right: 16,
      top: 6,
      bottom: 6
    })
  }

  @Builder
  InputBar() {
    Row() {
      TextInput({
        placeholder: 'Type your message...',
        text: this.inputText
      })
        .height(46)
        .layoutWeight(1)
        .fontSize(15)
        .backgroundColor('#F3F4F6')
        .borderRadius(23)
        .padding({
          left: 16,
          right: 16
        })
        .onChange((value: string) => {
          this.inputText = value;
        })
        .enabled(!this.isSending)

      Button(this.isSending ? '...' : 'Send')
        .height(46)
        .width(76)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .backgroundColor(this.isSending ? '#9CA3AF' : '#2563EB')
        .borderRadius(23)
        .margin({ left: 10 })
        .enabled(!this.isSending)
        .onClick(() => {
          this.sendMessage();
        })
    }
    .width('100%')
    .padding({
      left: 14,
      right: 14,
      top: 12,
      bottom: 16
    })
    .backgroundColor('#FFFFFF')
  }

  build() {
    Column() {
      this.Header()

      Scroll(this.scroller) {
        Column() {
          ForEach(
            this.messages,
            (item: ChatMessage) => {
              this.MessageBubble(item)
            },
            (item: ChatMessage) => item.id
          )
        }
        .width('100%')
        .padding({
          top: 8,
          bottom: 8
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      this.InputBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#EEF2FF')
  }
}