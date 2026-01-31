# CLAUDE.md

## Working Guidelines

1. **Think first, then act.** Read the codebase for relevant files before making changes.
2. **Check in before major changes.** Verify the plan with me before implementing significant modifications.
3. **Keep explanations high-level.** Provide concise summaries of what changes were made at each step.
4. **Simplicity is key.** Make every task and code change as simple as possible. Avoid massive or complex changes. Every change should impact as little code as possible.
5. **Maintain documentation.** Keep the architecture documentation up to date (see ARCHITECTURE.md).
6. **Never speculate.** Always read and investigate files before answering questions about them. Give grounded, hallucination-free answers.

---

## Project Structure

```
/
├── new-project/              # React frontend (Create React App)
│   ├── src/
│   │   ├── App.js            # Main app with React Router
│   │   └── index.js          # Entry point
│   └── package.json
│
├── node-auth-tutorial/       # Express backend with Passport auth
│   ├── app.js                # Express configuration
│   ├── bin/www               # Server entry point
│   ├── routes/
│   │   ├── index.js          # Auth routes (register, login, logout)
│   │   └── users.js          # Protected routes
│   └── views/                # Jade templates
│
├── terraform/                # Infrastructure as Code
│   └── s3_evidence_store/    # S3 bucket configuration
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── s3_bucket.tf              # Root Terraform config
```

---

## Commands

### React Frontend (new-project)
```bash
cd new-project
npm install          # Install dependencies
npm start            # Start dev server (port 3000)
npm run build        # Production build
npm test             # Run tests
```

### Express Backend (node-auth-tutorial)
```bash
cd node-auth-tutorial
npm install          # Install dependencies
npm start            # Start server (default port 3000)
```

### Terraform
```bash
terraform init       # Initialize
terraform plan       # Preview changes
terraform apply      # Apply changes
terraform fmt        # Format files
terraform validate   # Validate configuration
```

---

## Tech Stack

| Layer          | Technology                          |
|----------------|-------------------------------------|
| Frontend       | React 18, React Router 6            |
| Backend        | Express 4, Passport.js, bcrypt      |
| Templates      | Jade (Pug)                          |
| Infrastructure | Terraform, AWS S3                   |
| Auth           | passport-local, express-session     |

---

## Code Style

- **JavaScript:** Follow ESLint rules (react-app config for frontend)
- **Terraform:** Use `terraform fmt` before commits
- **Commits:** Keep changes atomic and focused
