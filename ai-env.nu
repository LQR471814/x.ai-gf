use ai.nu

{
	name: "llama.cpp"
	baseurl: "http://192.168.1.12:8080/v1"
	model_default: ""
	api_key: ""
	org_id: ""
	project_id: ""
    adapter: 'openai'
    temp_default: 0.0
    temp_min: 0.0
    temp_max: 1.0
    active: 0
} | ai ai-config-upsert-provider

ai ai-switch-provider "llama.cpp"

ai ai-config-env-prompts general {
    system: "You are a general purpose AI agent who is knowledgeable about writing. In the event that you need to search the web, simply try to recall it from memory."
    template: "{{}}"
	placeholder: "[]"
    description: "General prompt."
}

ai ai-switch-temperature 0

