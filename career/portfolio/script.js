const year = new Date().getFullYear();
const footer = document.querySelector("footer p");
if (footer && !footer.textContent.includes(String(year))) {
  footer.textContent = `Muhammad Faisal Khan · CS student, Air University · ${year}`;
}

document.querySelectorAll('a[href^="#"]').forEach((link) => {
  link.addEventListener("click", (event) => {
    const id = link.getAttribute("href");
    if (!id || id === "#") return;
    const target = document.querySelector(id);
    if (!target) return;
    event.preventDefault();
    target.scrollIntoView({ behavior: window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth" });
    target.setAttribute("tabindex", "-1");
    target.focus({ preventScroll: true });
  });
});
