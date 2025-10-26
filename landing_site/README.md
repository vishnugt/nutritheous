# Nutritheous Landing Page

A modern, responsive static landing page for the Nutritheous AI-powered nutrition tracking app.

## Features

- 🎨 **Modern Design**: Clean, professional design using the app's color scheme (#6366F1)
- 📱 **Fully Responsive**: Works seamlessly on desktop, tablet, and mobile devices
- ⚡ **Fast & Lightweight**: Pure HTML, CSS, and vanilla JavaScript - no frameworks
- ♿ **Accessible**: Semantic HTML and ARIA labels for screen readers
- 🚀 **SEO Optimized**: Proper meta tags and semantic structure
- 🎯 **Smooth Animations**: Intersection Observer API for fade-in effects
- 📸 **Screenshot Slider**: Interactive carousel showcasing app features

## Structure

```
landing_site/
├── index.html              # Main HTML file
├── css/
│   └── styles.css          # All styles with CSS variables
├── js/
│   └── main.js             # Interactive features
├── images/
│   ├── icon.png            # App logo
│   └── screenshots/        # App screenshots (6 images)
└── README.md               # This file
```

## Sections

1. **Navigation** - Sticky navbar with smooth scroll
2. **Hero Section** - Main value proposition with CTAs
3. **Open Source Highlight** - Emphasizes self-hostable nature
4. **Features** - 8 key features with icons
5. **How It Works** - 3-step process explanation
6. **Screenshots Gallery** - Interactive slider with app screens
7. **Tech Stack** - Technologies used
8. **CTA Section** - Final call-to-action
9. **Footer** - Links and legal info

## Key Selling Points

✅ **Open Source** - MIT licensed, fully transparent
✅ **Self-Hostable** - Complete control over your data
✅ **AI-Powered** - GPT-4 Vision for nutrition analysis
✅ **Privacy-First** - Your data, your server
✅ **Cross-Platform** - Android, iOS (coming soon), Web

## Customization

### Colors

The color scheme matches the Flutter app and is defined in CSS variables in `styles.css`:

```css
--primary: #6366F1;        /* Main brand color */
--primary-dark: #4F46E5;   /* Darker variant */
--primary-light: #818CF8;  /* Lighter variant */
--secondary: #10B981;      /* Green accent */
```

### Content

All content can be easily modified in `index.html`. Key areas:
- Hero headline and subtitle
- Feature descriptions
- Screenshot images
- Footer links

## Deployment

This is a static site that can be deployed to any web server or hosting platform.

### Option 1: GitHub Pages (Free)

1. Push the `landing_site` folder to a GitHub repository
2. Go to Settings → Pages
3. Select the branch and `/landing_site` folder
4. Your site will be live at `https://username.github.io/repo-name/`

### Option 2: Netlify (Free)

1. Create account at [netlify.com](https://netlify.com)
2. Drag and drop the `landing_site` folder
3. Get instant HTTPS URL
4. Optional: Add custom domain

### Option 3: Vercel (Free)

1. Install Vercel CLI: `npm i -g vercel`
2. Navigate to `landing_site` folder
3. Run `vercel`
4. Follow prompts for deployment

### Option 4: Traditional Web Server

Upload the entire `landing_site` folder to your web server via FTP/SFTP.

```bash
# Example with SCP
scp -r landing_site/ user@yourserver.com:/var/www/html/
```

### Option 5: Same Domain as API

If you want to serve from the same domain as your API (e.g., https://analyze.food):

1. Configure your web server (nginx/Apache) to serve static files
2. Copy `landing_site` contents to the web root
3. Configure reverse proxy for API at `/api` path

Example nginx config:
```nginx
server {
    listen 80;
    server_name analyze.food;

    root /var/www/landing_site;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Performance

- No external dependencies
- Minimal CSS/JS (< 50KB total)
- Optimized images
- Fast load times (< 1s on good connection)

## Accessibility

- Semantic HTML5
- ARIA labels where needed
- Keyboard navigation support
- High contrast ratios
- Screen reader friendly

## Development

To work on the site locally, simply open `index.html` in your browser or use a local server:

```bash
# Python 3
python -m http.server 8000

# Node.js
npx http-server

# PHP
php -S localhost:8000
```

Then visit `http://localhost:8000`

## Updates

### Adding New Screenshots

1. Add images to `images/screenshots/`
2. Update `index.html` in the `.screenshot-track` section:
```html
<div class="screenshot-item">
    <img src="images/screenshots/new-image.jpg" alt="Description">
</div>
```

### Changing Links

- Play Store link: Update `href` in both hero and CTA sections
- GitHub link: Already set to `https://github.com/vishnugt/nutritheous`
- iOS App Store: Remove `disabled` class when available

## License

Same as parent project - check main repository for license details.

## Credits

Built for the Nutritheous open-source project.
