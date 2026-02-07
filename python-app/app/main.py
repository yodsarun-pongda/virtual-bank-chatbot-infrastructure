from fastapi import FastAPI
from pydantic import BaseModel
import os

app = FastAPI(title="Virtual Bank Chatbot")


class ChatRequest(BaseModel):
    message: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/chat")
def chat(req: ChatRequest):
    model = os.getenv("OLLAMA_MODEL", "")
    return {
        "reply": f"Echo: {req.message}",
        "model": model,
    }
