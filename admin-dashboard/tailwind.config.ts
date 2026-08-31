import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "#09090b",
        foreground: "#fafafa",
        card: "#121215",
        "card-foreground": "#fafafa",
        border: "#27272a",
        muted: "#27272a",
        "muted-foreground": "#a1a1aa",
        ember: {
          50: "#fff8f1",
          100: "#feecdc",
          500: "#f97316",
          600: "#ea580c",
          700: "#c2410c",
        },
        velvet: {
          dark: "#0a0a0c",
          card: "#141418",
          border: "#26262e",
          accent: "#0f5c4c",
          gold: "#d4af37",
        },
      },
    },
  },
  plugins: [],
};
export default config;
