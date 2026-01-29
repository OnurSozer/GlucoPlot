/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#E8A87C',
          light: '#F8D4B4',
          dark: '#D4886C',
        },
        secondary: {
          DEFAULT: '#85C7DE',
          light: '#B8E0ED',
          dark: '#5BA3BC',
        },
        glucose: '#FF6B6B',
        'blood-pressure': '#E76F51',
        'heart-rate': '#FF8FA3',
        weight: '#9B8FD9',
        temperature: '#FFB347',
        oxygen: '#4ECDC4',
        success: '#4CAF50',
        warning: '#FF9800',
        error: '#E53935',
        info: '#2196F3',
        alert: {
          critical: '#D32F2F',
          high: '#F57C00',
          medium: '#FFB300',
          low: '#43A047',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
