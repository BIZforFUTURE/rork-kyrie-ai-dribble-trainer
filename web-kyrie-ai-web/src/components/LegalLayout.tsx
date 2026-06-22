import { Link } from "react-router-dom";
import { ReactNode } from "react";

const NAV: { label: string; to: string }[] = [
  { label: "Home", to: "/" },
  { label: "Support", to: "/support" },
  { label: "Privacy", to: "/privacy" },
  { label: "Terms", to: "/terms" },
  { label: "Privacy Choices", to: "/privacy-choices" },
];

type LegalLayoutProps = {
  title?: string;
  children: ReactNode;
};

const LegalLayout = ({ title, children }: LegalLayoutProps) => {
  return (
    <div className="min-h-screen bg-[#0B0B0F] text-zinc-100">
      <header className="sticky top-0 z-20 border-b border-white/5 bg-[#0B0B0F]/85 backdrop-blur">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-5 py-4">
          <Link to="/" className="flex items-center gap-2">
            <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-orange-500 text-sm font-black text-black">
              K
            </span>
            <span className="text-base font-extrabold tracking-tight">
              Kyrie AI
            </span>
          </Link>
          <nav className="hidden gap-6 text-sm font-medium text-zinc-400 sm:flex">
            {NAV.map((item) => (
              <Link
                key={item.to}
                to={item.to}
                className="transition-colors hover:text-orange-400"
              >
                {item.label}
              </Link>
            ))}
          </nav>
        </div>
      </header>

      <main className="mx-auto max-w-3xl px-5 py-12">
        {title ? (
          <h1 className="mb-8 text-3xl font-black tracking-tight sm:text-4xl">
            {title}
          </h1>
        ) : null}
        <div className="space-y-6 text-[15px] leading-relaxed text-zinc-300">
          {children}
        </div>
      </main>

      <footer className="border-t border-white/5 px-5 py-10">
        <div className="mx-auto flex max-w-5xl flex-col gap-4 text-sm text-zinc-500 sm:flex-row sm:items-center sm:justify-between">
          <span>© {new Date().getFullYear()} Kyrie AI Dribble Trainer</span>
          <nav className="flex flex-wrap gap-x-5 gap-y-2">
            {NAV.map((item) => (
              <Link
                key={item.to}
                to={item.to}
                className="transition-colors hover:text-orange-400"
              >
                {item.label}
              </Link>
            ))}
          </nav>
        </div>
      </footer>
    </div>
  );
};

export const Section = ({
  heading,
  children,
}: {
  heading: string;
  children: ReactNode;
}) => (
  <section className="space-y-3">
    <h2 className="text-xl font-bold text-zinc-100">{heading}</h2>
    {children}
  </section>
);

export default LegalLayout;
