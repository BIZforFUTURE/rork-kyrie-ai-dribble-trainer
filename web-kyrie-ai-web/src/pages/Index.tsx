import { Link } from "react-router-dom";
import LegalLayout from "@/components/LegalLayout";

const links: { label: string; to: string; desc: string }[] = [
  { label: "Support", to: "/support", desc: "Get help, contact us, or manage your subscription." },
  { label: "Privacy Policy", to: "/privacy", desc: "How Kyrie AI handles your data." },
  { label: "Terms of Use", to: "/terms", desc: "The rules for using the app." },
  { label: "Privacy Choices", to: "/privacy-choices", desc: "Access, export, or delete your data." },
];

const Index = () => {
  return (
    <LegalLayout>
      <div className="mb-12">
        <span className="inline-block rounded-full bg-orange-500/15 px-3 py-1 text-xs font-bold uppercase tracking-widest text-orange-400">
          AI Basketball Trainer
        </span>
        <h1 className="mt-5 text-4xl font-black leading-tight tracking-tight sm:text-5xl">
          Kyrie AI Dribble Trainer
        </h1>
        <p className="mt-4 max-w-xl text-lg text-zinc-400">
          Your personal AI ball-handling coach. Take a quick skills assessment,
          get a personalized daily dribbling plan, and watch your ball handler
          score climb as you train.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        {links.map((item) => (
          <Link
            key={item.to}
            to={item.to}
            className="group rounded-2xl border border-white/5 bg-white/[0.03] p-5 transition-colors hover:border-orange-500/40 hover:bg-white/[0.05]"
          >
            <div className="flex items-center justify-between">
              <h2 className="text-lg font-bold text-zinc-100">{item.label}</h2>
              <span className="text-orange-400 transition-transform group-hover:translate-x-1">
                →
              </span>
            </div>
            <p className="mt-2 text-sm text-zinc-400">{item.desc}</p>
          </Link>
        ))}
      </div>

      <p className="mt-12 text-sm text-zinc-500">
        These pages support App Store publishing, account help, privacy
        requests, and product support for the Kyrie AI Dribble Trainer iOS app.
      </p>
    </LegalLayout>
  );
};

export default Index;
