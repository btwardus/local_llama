from transformers import AutoModelForCausalLM, AutoTokenizer
import gradio as gr
import torch

is_generating = True

def load_model_and_tokenizer():
    model_name = "TheBloke/Phind-CodeLlama-34B-v2-GPTQ"
    model = AutoModelForCausalLM.from_pretrained(model_name, device_map="auto")
    tokenizer = AutoTokenizer.from_pretrained(model_name, use_fast=True)
    return model, tokenizer


def generate_response(model, tokenizer, user_input, max_response_length=512):
    # start_time = time.time()
    # tokens_generated = 0
    global is_generating

    system_message ="This is a Python Coding Assistant, a state-of-the-art large language model trained to assist with Python programming questions, debugging, code writing, and explanation. Whether you're a beginner looking for help with basic syntax, or an experienced developer seeking advanced insights, the Python Coding Assistant is here to help you."

    prompt = f"""#### System Prompt
{system_message}
### User Message
{user_input}

### Assistant

"""
    input_ids = tokenizer(prompt, return_tensors="pt").input_ids.cuda()
    prompt_length = input_ids.shape[1]
    max_length = prompt_length + max_response_length
    decoded_text = ""

    for i in range(prompt_length, max_length):
        if not is_generating:  # Check the flag in the loop
            break
        outputs = model(input_ids)
        print (outputs)
        next_token_logits = outputs.logits[:, -1, :]
        next_token = torch.argmax(next_token_logits, dim=-1).unsqueeze(-1)
        
        input_ids = torch.cat([input_ids, next_token], dim=-1)
        
        new_decoded_text = tokenizer.decode(input_ids[0][prompt_length:])
        yield new_decoded_text[len(decoded_text):]
        decoded_text = new_decoded_text

        # tokens_generated += 1

    # elapsed_time = time.time() - start_time
    # tokens_per_sec = (tokens_generated / elapsed_time)
    # yield f"\n\nTokens per Second: {tokens_per_sec:.2f}"


def bot_fn(history):
    last_user_message = history[-1][0]
    history[-1][1] = ""

    for token in generate_response(model, tokenizer, last_user_message):
        history[-1][1] += token
        yield history


def setup_gradio(model, tokenizer):
    global is_generating

    with gr.Blocks() as app:
        chatbot = gr.Chatbot()
        msg = gr.Textbox(label="Enter your prompt:")
        clear = gr.Button("Clear")
        stop = gr.Button("Stop")  # Stop button

        def stop_generation():  # Function to handle stop button click
            global is_generating
            is_generating = False

        stop.click(stop_generation)  # Attach the function to stop button


        def user_fn(user_message, history):
            return "", history + [[user_message, None]]

        msg.submit(user_fn, [msg, chatbot], [msg, chatbot], queue=True).then(
            bot_fn, chatbot, chatbot
        )
        clear.click(lambda: None, None, chatbot, queue=True)

    app.queue()
    app.launch()

if __name__ == "__main__":
    model, tokenizer = load_model_and_tokenizer()
    setup_gradio(model, tokenizer)