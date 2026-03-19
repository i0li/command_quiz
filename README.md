# command-quiz

A simple CLI tool that randomly shows command-line quiz questions at intervals.

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/i0li/command_quiz.git
cd command-quiz
```

---

### 2. Setup configuration

```bash
cp config.example.env config.env
cp questions.example.yaml questions.yaml
```

---

### 3. Run

```bash
chmod +x run.sh
./run.sh
```

---

## ⚙️ Configuration

Edit `config.env` to control the delay between quizzes:

```env
# Delay range (in seconds)
MIN_DELAY=10
MAX_DELAY=30
```

---

## 🧠 Add Your Own Questions

Edit `questions.yaml`:

```yaml
- q: Show a list of files in the current directory
  a: ls
```

### Format

```yaml
- q: <question>
  a: <answer>
```

---

## 📝 Logs

Logs are saved automatically in the `logs/` directory.

Each file is created per day:

```
logs/20260319.log
```

---

## 🛑 Stop

Press `Ctrl + C` to stop the script safely.

---

## 📌 Notes

* `questions.yaml` is ignored by Git
* Use `questions.example.yaml` as a template

