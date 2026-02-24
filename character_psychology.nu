source ai_env.nu
source mem_tools.nu

# characterization requires fleshing out the psychological state of the character themselves.
#
# this is largely made up of the rational, emotional, and instinctual
#
# emotional state can be derived from the events that have occurred to the character
#
# instinctual habits and learned abstractions are largely part of the character
# setting (which is part of broader developmental considerations for the character)

const SCHEDULE = "
### **Morning (7:00 AM – 12:00 PM)**
- **7:00 AM**: Wake up, enjoy a healthy breakfast (e.g., oatmeal with berries)
- **8:00 AM**: Attend morning academic session (e.g., group project review for her campus sustainability club)
- **9:30 AM**: Quick walk to campus library for focused study on upcoming exams
- **11:00 AM**: Collaborate with Maya and Jordan on a campus-wide initiative for the Multicultural Festival

---

### **Afternoon (12:00 PM – 8:45 PM)**
- **12:00 PM**: Lunch with Alex and classmates (healthy, schedule-friendly meal)
- **1:00 PM**: Social break with friends at campus café
- **3:45 PM – 3:55 PM**: Participate in the **Campus Multicultural Festival** with Maya, Alex, and Jordan (live cultural performances and food stalls)
- **3:55 PM – 5:15 PM**: Structured study block (reviewing course materials for the week)
- **5:30 PM – 7:00 PM**: Second study block (preparing for a campus debate team practice)
- **7:15 PM – 8:45 PM**: Third study block (finalizing group project deliverables for the Multicultural Festival)

---

### **Evening (8:45 PM – 11:30 PM)**
- **8:45 PM**: Dinner with Maya, Alex, and Jordan at a local café (light meal with shared storytelling)
- **9:30 PM**: Wind-down activities (e.g., journaling, light stretching, or watching a short documentary about campus diversity initiatives)
- **10:30 PM**: Prepare for tomorrow’s academic tasks (e.g., review notes for the next day’s class)
- **11:00 PM**: Sleep (consistent bedtime routine to maintain energy for the next week)
"

let prompt = $"# Context

The current datetime is: (date now | format date '%Y-%m-%d %H:%M %A')

You can access general information about the world and the characters in it \(including claire\) using the 'mem_query' tool.

## Schedule

Claire's schedule for today is:

($SCHEDULE)

## Principles of characterization

- Characterization requires fleshing out the psychological state of the character themselves.
- This is largely made up of the rational, emotional, and instinctual.
- Rational is simply the actual thoughts running through the character themselves.
- Emotional state can be derived from the events that have occurred to the character.
- Instinctual habits and learned abstractions are largely part of the character setting.

# Task

Your task is to characterize Claire during this moment, respond with a detailed characterization covering all 3 aspects mentioned."

$prompt | ai ai-do general

