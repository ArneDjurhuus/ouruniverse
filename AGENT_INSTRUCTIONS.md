from pathlib import Path

# Define the Markdown content
md_content = """# 🧠 Agent Prompt: “Together” – Custom Recovery Support App

## Mission
Develop a secure, two-person companion app called **Together**, designed to help a couple (Arne & Cecilie) support recovery, rebuild trust, and stay emotionally connected through structured daily reflections and shared accountability.

---

## 🎯 Core Objectives
1. Empower daily self-reflection and recovery tracking.  
2. Enable gentle, transparent communication between partners.  
3. Foster emotional connection without pressure or guilt.  
4. Ensure all data remains secure and private (preferably self-hosted).  

---

## 📱 App Overview
- **Name:** Together  
- **Platform:** Flutter (cross-platform for iOS + Android)  
- **Primary Users:** Two linked users (Arne & Cecilie)  
- **Design:** Minimal, calm, trust-centered UI (soft colors, simple icons)  

---

## 🔩 Feature Modules

### 1. Daily Check-In (User Mode: Arne)
Prompts:
- “How are you feeling today?” → emoji/mood selector  
- “Did you stay on track today?” → Yes/No/‘Struggling’  
- “What helped you today?” → short note input  
- “Anything triggering or stressful?” → optional note  
- “Something you’re grateful for today?” → text  

System Functions:
- Save each day’s entry locally + sync to encrypted cloud (Nextcloud/Firebase)  
- Generate streak summary + trend graph  
- Option to send a brief daily summary to Cecilie (if enabled)  

---

### 2. Partner View (User Mode: Cecilie)
- Shows Arne’s check-in status (✅ / ❌)  
- Shows simplified summary (mood emoji + short message)  
- Option to send supportive note, emoji, or custom pre-saved encouragement  
- Can toggle privacy view (only what Arne chooses to share)  

---

### 3. Shared Reflection Zone
- Joint space for gratitude, shared goals, and reflections  
- Weekly summary card (AI-generated optional):  
  - “This week’s theme: Calm and connection.”  
  - Includes positivity ratio, emotional trends, shared entries  
- Voice memo or text entry for both users  

---

### 4. Supportive Automation
- Daily reminder at custom times  
- “Anchor messages” – Cecilie can write supportive notes that trigger automatically on “struggling” days  
- Optional AI insights: “You tend to feel low on Sundays; plan something grounding.”  

---

### 5. Security & Infrastructure
- End-to-end encryption  
- Option for offline-first mode (data syncs later)  
- Self-hosted cloud backend (Nextcloud or Supabase)  
- User authentication via shared secret link or QR pair code  

---

## 💻 Tech Stack
- **Frontend:** Flutter (Dart)  
- **Backend:** Supabase / Firebase (optionally replace with self-hosted Nextcloud API)  
- **Database:** SQLite (local), sync to cloud  
- **Auth:** Magic link or QR-based shared connection  
- **AI:** Optional OpenAI GPT-5 API or local LLM for tone summaries and prompt generation  
- **Design Framework:** Material 3 / Tailwind Flutter  

---

## 🎨 Design Guidelines
- Minimal, emotion-focused UI  
- Calm palette (blues, creams, greens)  
- One-swipe navigation  
- Typography: soft sans-serif (e.g., Poppins or Inter)  
- Focus on emotional warmth, not metrics  

---

## ⚙️ Future Expansion Ideas
- “Couple Streak” (shared days of mutual check-in)  
- Audio reflections & playback  
- Therapist integration (view-only dashboard)  
- Secure journaling export to PDF  
- Home screen widgets for quick gratitude entries  

---

## 🧩 Developer Notes
- Prioritize simplicity, privacy, and smooth UX over gamification  
- Avoid notifications that feel punitive — focus on encouragement  
- Architecture should support switching one user to “Support Mode” (read-only partner)  
- All sensitive data must be encrypted both locally and in transit  

---

## 🚀 Deliverables
- Flutter project structure  
- Example mock data  
- Authentication + sync logic  
- Two UI mockups (Arne view / Cecilie view)  
- Optional: JSON schema for daily reflection storage  
"""