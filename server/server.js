import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import OpenAI from 'openai';

dotenv.config({ override: true });

const apiKey = process.env.DASHSCOPE_API_KEY;
const baseURL = process.env.DASHSCOPE_BASE_URL || 'https://dashscope-intl.aliyuncs.com/compatible-mode/v1';

console.log('Loaded DASHSCOPE_API_KEY:', apiKey ? `${apiKey.slice(0, 8)}...${apiKey.slice(-4)}` : 'MISSING');
console.log('Loaded DASHSCOPE_BASE_URL:', baseURL);

const app = express();
const port = process.env.PORT || 3000;

const client = new OpenAI({
  apiKey,
  baseURL
});

app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/health', (req, res) => {
  res.json({
    ok: true,
    service: 'arkui-qwen-chatbot-server'
  });
});

app.post('/api/chat', async (req, res) => {
  try {
    const rawMessages = Array.isArray(req.body.messages) ? req.body.messages : [];

    if (rawMessages.length === 0) {
      return res.status(400).json({
        error: 'messages is required'
      });
    }

    const messages = rawMessages.map((message) => {
      const role = message.role === 'assistant' ? 'assistant' : 'user';

      return {
        role,
        content: String(message.content || '')
      };
    });

    const completion = await client.chat.completions.create({
      model: process.env.QWEN_MODEL || 'qwen-max',
      messages: [
        {
          role: 'system',
          content: 'You are a helpful chatbot inside a HarmonyOS ArkUI demo app. Keep answers clear and concise.'
        },
        ...messages
      ],
      temperature: 0.7
    });

    const reply = completion.choices?.[0]?.message?.content || 'No response text returned.';

    res.json({
      reply
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: 'Qwen request failed'
    });
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`ArkUI Qwen chatbot server running at http://0.0.0.0:${port}`);
});