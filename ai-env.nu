use ai.nu

{
	name: "llama.cpp"
	baseurl: "http://127.0.0.1:8080/v1"
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
    system: ""
    template: "{{}}"
	placeholder: "[]"
    description: "General prompt."
}

ai ai-config-env-prompts short-thinking {
    system: "You are in a hurry, don't spend overly long on thinking about the user's request and just answer it.
Always output JSON without extra spaces or newlines."
    template: "{{}}"
	placeholder: "[]"
    description: "Short thinking."
}

ai ai-config-env-prompts long-thinking {
    system: "You are cautious and detailed when processing the user's request, you double-check and think long about the user's request.
Always output JSON without extra spaces or newlines."
    template: "{{}}"
	placeholder: "[]"
    description: "Long thinking."
}

