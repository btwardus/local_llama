from ctransformers import AutoModelForCausalLM, Config, AutoConfig
import gradio as gr
import time


system_message = "Respond as an expert python developer using python best practices."

prompt_template = f"""
### System Prompt
{system_message}

### User Message

"""
#model = ".\models\codellama-13b-instruct.Q5_K_M.gguf"
model = ".\models\phind-codellama-34b-v2.Q5_K_M.gguf"

config = Config( top_k=40, top_p=0.95, temperature=0.8, repetition_penalty=1.1, last_n_tokens=64, seed=-1, batch_size=8, threads=-1, max_new_tokens=512, stop=None, stream=False, reset=True, context_length=-1, gpu_layers=0, mmap=True, mlock=False)
auto_config = AutoConfig(config,"llama")

def load_llm():
    #might need to add config here
    llm = AutoModelForCausalLM.from_pretrained(
        model,
        device_map='auto',
        config=auto_config
    )
    print(llm.config)
    return llm

def model_inference(input):
    llm = load_llm()
    response = llm(prompt_template+input,stream=True)
    return response

title = "Local Llama"


with gr.Blocks() as llm_app:
    chatbot = gr.Chatbot()
    msg = gr.Textbox(label="Enter your prompt:")
    clear = gr.Button("Clear")

    def user(user_message, history):
        return "", history + [[user_message, None]]

    def bot(history):
        bot_message = model_inference(input=history[-1][0])
        history[-1][1] = ""
        for character in bot_message:
            history[-1][1] += str(character)
            time.sleep(0.03)
            yield history

    msg.submit(user, [msg, chatbot], [msg, chatbot], queue=False).then(
        bot, chatbot, chatbot
    )
    clear.click(lambda: None, None, chatbot, queue=False)
    
llm_app.queue()
llm_app.launch()