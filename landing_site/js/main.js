// Main JavaScript for Nutritheous Landing Page

// Hero Carousel
const heroCarouselTrack = document.getElementById('heroCarouselTrack');
const heroCarouselDots = document.getElementById('heroCarouselDots');
const heroCarouselPrev = document.getElementById('heroCarouselPrev');
const heroCarouselNext = document.getElementById('heroCarouselNext');

if (heroCarouselTrack && heroCarouselDots) {
    const slides = heroCarouselTrack.querySelectorAll('.hero-carousel-item');
    let currentSlide = 0;
    let autoplayInterval;

    // Create dots
    slides.forEach((_, index) => {
        const dot = document.createElement('button');
        dot.classList.add('hero-carousel-dot');
        if (index === 0) dot.classList.add('active');
        dot.setAttribute('aria-label', `Go to slide ${index + 1}`);
        dot.addEventListener('click', () => goToSlide(index));
        heroCarouselDots.appendChild(dot);
    });

    const dots = heroCarouselDots.querySelectorAll('.hero-carousel-dot');

    function goToSlide(index) {
        // Remove active class from current slide and dot
        slides[currentSlide].classList.remove('active');
        dots[currentSlide].classList.remove('active');

        // Set new current slide
        currentSlide = index;

        // Add active class to new slide and dot
        slides[currentSlide].classList.add('active');
        dots[currentSlide].classList.add('active');

        // Reset autoplay
        resetAutoplay();
    }

    function nextSlide() {
        const next = (currentSlide + 1) % slides.length;
        goToSlide(next);
    }

    function prevSlide() {
        const prev = (currentSlide - 1 + slides.length) % slides.length;
        goToSlide(prev);
    }

    function startAutoplay() {
        autoplayInterval = setInterval(nextSlide, 4000); // Change slide every 4 seconds
    }

    function stopAutoplay() {
        clearInterval(autoplayInterval);
    }

    function resetAutoplay() {
        stopAutoplay();
        startAutoplay();
    }

    // Arrow button event listeners
    if (heroCarouselPrev) {
        heroCarouselPrev.addEventListener('click', prevSlide);
    }

    if (heroCarouselNext) {
        heroCarouselNext.addEventListener('click', nextSlide);
    }

    // Start autoplay
    startAutoplay();

    // Pause autoplay on hover
    heroCarouselTrack.addEventListener('mouseenter', stopAutoplay);
    heroCarouselTrack.addEventListener('mouseleave', startAutoplay);
}

// Smooth scroll for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const offset = 80; // Account for fixed navbar
            const targetPosition = target.offsetTop - offset;
            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    });
});

// Mobile Menu Toggle
const mobileMenuBtn = document.getElementById('mobileMenuBtn');
const navLinks = document.querySelector('.nav-links');

if (mobileMenuBtn) {
    mobileMenuBtn.addEventListener('click', () => {
        navLinks.classList.toggle('active');
        mobileMenuBtn.classList.toggle('active');
    });

    // Close mobile menu when clicking a link
    document.querySelectorAll('.nav-links a').forEach(link => {
        link.addEventListener('click', () => {
            navLinks.classList.remove('active');
            mobileMenuBtn.classList.remove('active');
        });
    });

    // Close mobile menu when clicking outside
    document.addEventListener('click', (e) => {
        if (!navLinks.contains(e.target) && !mobileMenuBtn.contains(e.target)) {
            navLinks.classList.remove('active');
            mobileMenuBtn.classList.remove('active');
        }
    });
}

// Screenshot Slider
const screenshotTrack = document.getElementById('screenshotTrack');
const prevBtn = document.getElementById('prevBtn');
const nextBtn = document.getElementById('nextBtn');

if (screenshotTrack && prevBtn && nextBtn) {
    const scrollAmount = 320; // Width of one screenshot + gap

    prevBtn.addEventListener('click', () => {
        screenshotTrack.scrollBy({
            left: -scrollAmount,
            behavior: 'smooth'
        });
    });

    nextBtn.addEventListener('click', () => {
        screenshotTrack.scrollBy({
            left: scrollAmount,
            behavior: 'smooth'
        });
    });

    // Auto-hide buttons at scroll boundaries
    screenshotTrack.addEventListener('scroll', () => {
        const maxScroll = screenshotTrack.scrollWidth - screenshotTrack.clientWidth;

        if (screenshotTrack.scrollLeft <= 0) {
            prevBtn.style.opacity = '0.3';
            prevBtn.style.cursor = 'default';
        } else {
            prevBtn.style.opacity = '1';
            prevBtn.style.cursor = 'pointer';
        }

        if (screenshotTrack.scrollLeft >= maxScroll - 5) {
            nextBtn.style.opacity = '0.3';
            nextBtn.style.cursor = 'default';
        } else {
            nextBtn.style.opacity = '1';
            nextBtn.style.cursor = 'pointer';
        }
    });

    // Initial button state
    screenshotTrack.dispatchEvent(new Event('scroll'));
}

// Navbar background on scroll
const navbar = document.querySelector('.navbar');
let lastScrollTop = 0;

window.addEventListener('scroll', () => {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

    if (scrollTop > 100) {
        navbar.style.boxShadow = '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)';
    } else {
        navbar.style.boxShadow = '0 1px 2px 0 rgb(0 0 0 / 0.05)';
    }

    lastScrollTop = scrollTop;
});

// Intersection Observer for fade-in animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe feature cards and other elements
document.querySelectorAll('.feature-card, .step, .tech-item').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// Add active state to mobile menu button
if (mobileMenuBtn) {
    const style = document.createElement('style');
    style.textContent = `
        .mobile-menu-btn.active span:nth-child(1) {
            transform: rotate(45deg) translate(5px, 5px);
        }
        .mobile-menu-btn.active span:nth-child(2) {
            opacity: 0;
        }
        .mobile-menu-btn.active span:nth-child(3) {
            transform: rotate(-45deg) translate(7px, -6px);
        }
        @media (max-width: 768px) {
            .nav-links.active {
                display: flex;
                flex-direction: column;
                position: absolute;
                top: 100%;
                left: 0;
                right: 0;
                background: white;
                padding: 1rem;
                box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1);
                gap: 1rem;
            }
        }
    `;
    document.head.appendChild(style);
}

// Add keyboard navigation for slider
if (screenshotTrack) {
    document.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowLeft' && prevBtn) {
            prevBtn.click();
        } else if (e.key === 'ArrowRight' && nextBtn) {
            nextBtn.click();
        }
    });
}

// Lazy loading for images
if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                if (img.dataset.src) {
                    img.src = img.dataset.src;
                    img.removeAttribute('data-src');
                }
                observer.unobserve(img);
            }
        });
    });

    document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
    });
}

// Add loading animation
window.addEventListener('load', () => {
    document.body.classList.add('loaded');
});

// Performance: Debounce scroll events
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Apply debouncing to scroll handler
const debouncedScroll = debounce(() => {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

    if (scrollTop > 100) {
        navbar.style.boxShadow = '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)';
    } else {
        navbar.style.boxShadow = '0 1px 2px 0 rgb(0 0 0 / 0.05)';
    }
}, 10);

window.addEventListener('scroll', debouncedScroll);

// Console welcome message
console.log('%c🥗 Nutritheous', 'font-size: 24px; font-weight: bold; color: #6366F1;');
console.log('%cOpen source nutrition tracking powered by AI', 'font-size: 14px; color: #6B7280;');
console.log('%cGitHub: https://github.com/vishnugt/nutritheous', 'font-size: 12px; color: #10B981;');
