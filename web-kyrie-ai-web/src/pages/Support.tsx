import LegalLayout, { Section } from "@/components/LegalLayout";

const SUPPORT_EMAIL = "olivernasatir@gmail.com";

const Support = () => {
  return (
    <LegalLayout title="Support">
      <p>
        Need help with <strong>Kyrie AI Dribble Trainer</strong> on iPhone? We're
        here to help you get back to training.
      </p>

      <Section heading="Contact us">
        <p>
          Email us at{" "}
          <a
            href={`mailto:${SUPPORT_EMAIL}`}
            className="font-semibold text-orange-400 underline"
          >
            {SUPPORT_EMAIL}
          </a>
          . We typically respond within 2–3 business days.
        </p>
      </Section>

      <Section heading="What to include">
        <p>To help us resolve your issue faster, please include:</p>
        <ul className="list-disc space-y-1 pl-6">
          <li>App version (Settings → About, or the App Store listing)</li>
          <li>Your device model (e.g. iPhone 15 Pro)</li>
          <li>Your iOS version</li>
          <li>A short description of what happened and any screenshots</li>
        </ul>
      </Section>

      <Section heading="Subscriptions &amp; billing">
        <p>
          Kyrie AI Pro is offered as an auto-renewing subscription (monthly and
          yearly, with a free trial on the yearly plan). Purchases, renewals, and
          cancellations are managed by Apple through your Apple ID.
        </p>
        <ul className="list-disc space-y-1 pl-6">
          <li>
            To manage or cancel: open the iOS{" "}
            <strong>Settings</strong> app → tap your name →{" "}
            <strong>Subscriptions</strong> → Kyrie AI.
          </li>
          <li>
            To restore a previous purchase, open the app and tap{" "}
            <strong>Restore Purchases</strong> on the paywall or profile screen.
          </li>
          <li>
            For refund requests, visit{" "}
            <a
              href="https://reportaproblem.apple.com"
              className="font-semibold text-orange-400 underline"
              target="_blank"
              rel="noreferrer"
            >
              reportaproblem.apple.com
            </a>
            .
          </li>
        </ul>
      </Section>

      <Section heading="Your data">
        <p>
          To request access to, export, or deletion of your data, see our{" "}
          <a href="/privacy-choices" className="font-semibold text-orange-400 underline">
            Privacy Choices
          </a>{" "}
          page or email us directly.
        </p>
      </Section>
    </LegalLayout>
  );
};

export default Support;
