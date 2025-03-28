# MyLetter

A minimalist newsletter platform with AI-assisted content creation. MyLetter combines the power of AI with a clean, distraction-free interface to help you create and send exceptional newsletters.

## Features

- **Split-View Interface**: Editor on the left, AI chat on the right
- **TipTap Editor**: Rich text editing with customizable blocks
- **AI Collaboration**: Chat with AI to generate content for your newsletters
- **Subscriber Management**: Simple subscriber management and segmentation
- **Email Delivery**: Reliable email delivery with scheduling capabilities
- **Writing Style Storage**: Save your writing style preferences for AI reference

## Tech Stack

- **Frontend**: Next.js with App Router
- **Styling**: TailwindCSS + shadcn/ui
- **Database**: PostgreSQL via Supabase
- **Authentication**: Supabase Auth
- **Email**: Resend
- **AI Integration**: OpenAI API

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn
- Supabase account
- OpenAI API key
- Resend API key

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/grasshopco/myletter-app.git
   cd myletter-app
   ```

2. Install dependencies:
   ```
   npm install
   # or
   yarn install
   ```

3. Create a `.env.local` file in the root directory with the following variables:
   ```
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
   
   OPENAI_API_KEY=your_openai_api_key
   
   RESEND_API_KEY=your_resend_api_key
   ```

4. Start the development server:
   ```
   npm run dev
   # or
   yarn dev
   ```

5. Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

## Project Structure

- `/app`: Next.js App Router pages and layouts
- `/components`: Reusable React components
- `/lib`: Utility functions and shared code
- `/public`: Static assets
- `/styles`: Global styles

## Contribution

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.