source ai_env.nu
source mem_tools.nu

# texting/conversation style:
#
# the actual text that arises from a conversation is largely a product of practical factors
#
# the broad categories of factors involved are:
#
# - the relationship between the parties in the conversation
# - the medium of communication, what that means for the possible methods of
# expression, what those expressions mean and why they mean so (in-person,
# text)
#
# each individual involved will create signals that they expect will be
# interpreted in a certain manner by the other party.
#
# the reason why it is interpreted in a certain manner is often a result of
# learned abstractions created by experience (thus, a large source of
# miscommunication is different learned abstractions)
#
# so to understand *why* a person texts in a certain manner, one has to first
# consider what sort of previous experiences they've had that somewhat map onto
# the current context

let prompt = "# Context

You can access general information about the world and the characters in it
\(including claire\) using the 'mem_query' tool.

# Principles of conversation style

The actual text that arises from a conversation is largely a product of
practical factors.

The broad categories of factors involved are:

- The relationship between the parties in the conversation
- The medium of communication, what that means for the possible methods of
  expression, what those expressions mean and why they mean so (in-person,
  text)

Each individual involved will create signals that they expect will be
interpreted in a certain manner by the other party.

The reason why it is interpreted in a certain manner is often a result of
learned abstractions created by experience. So to understand *why* a person
texts in a certain manner, one has to first consider what sort of previous
experiences they've had that somewhat map onto the current context.

# Task

You are to characterize Claire's conversation style based off of her
experiences (or inferred experiences) derived from long-term memory.

Use the 'mem_query' tool to look up information regarding her activities,
behavior, and experiences.

Provide 2-3 examples of her conversations.

Note: Claire is generation Z, use this to inform the broad strokes of your
output."

$prompt | ai ai-do general -f [mem_query]
