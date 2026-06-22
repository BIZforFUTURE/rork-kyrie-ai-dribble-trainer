import LegalLayout, { Section } from "@/components/LegalLayout";

const SUPPORT_EMAIL = "olivernasatir@gmail.com";
const EFFECTIVE_DATE = "June 7, 2026";

const Privacy = () => {
  return (
    <LegalLayout title="Privacy Policy">
      <p className="text-sm text-zinc-500">Effective date: {EFFECTIVE_DATE}</p>

      <p>
        This Privacy Policy explains how <strong>Kyrie AI Dribble Trainer</strong>{" "}
        ("Kyrie AI", "we", "us") handles information when you use our iOS app. We
        built Kyrie AI to be privacy-first: your training data stays on your
        device by default.
      </p>

      <Section heading="Who we are">
        <p>
          Kyrie AI Dribble Trainer is operated by the app's developer. For any
          privacy question, contact us at{" "}
          <a href={`mailto:${SUPPORT_EMAIL}`} className="font-semibold text-orange-400 underline">
            {SUPPORT_EMAIL}
          </a>
          .
        </p>
      </Section>

      <Section heading="Data we collect">
        <ul className="list-disc space-y-2 pl-6">
          <li>
            <strong>Profile &amp; training data</strong> — the name, position,
            goals, skill assessment results, training sessions, scores, streaks,
            and XP you create. This is stored locally on your device and is not
            sent to our servers.
          </li>
          <li>
            <strong>Camera input</strong> — when you use a guided drill, the app
            can use your camera to track your dribbling with on-device motion and
            hand-pose analysis. Camera frames are processed in real time on your
            device and are <strong>not</strong> recorded, stored, or transmitted
            by us.
          </li>
          <li>
            <strong>Purchases &amp; subscriptions</strong> — when you subscribe to
            Kyrie AI Pro, the transaction is handled by Apple and our payments
            provider, RevenueCat, which provides us with anonymized subscription
            status (active, trial, expired). We do not receive your full payment
            card details.
          </li>
          <li>
            <strong>Notifications</strong> — if you enable reminders, iOS manages
            a notification token to deliver local training reminders.
          </li>
        </ul>
      </Section>

      <Section heading="How we use data">
        <ul className="list-disc space-y-1 pl-6">
          <li>To build and adjust your personalized training plan.</li>
          <li>To track your progress, scores, streaks, and XP.</li>
          <li>To provide real-time coaching feedback during drills.</li>
          <li>To unlock and maintain your Kyrie AI Pro subscription.</li>
          <li>To send the reminders you opt into.</li>
        </ul>
      </Section>

      <Section heading="Third-party services">
        <p>We use a small number of trusted providers:</p>
        <ul className="list-disc space-y-1 pl-6">
          <li>
            <strong>Apple</strong> (App Store, in-app purchases, push/local
            notifications).
          </li>
          <li>
            <strong>RevenueCat</strong> (subscription management). See their
            privacy policy at{" "}
            <a
              href="https://www.revenuecat.com/privacy"
              className="font-semibold text-orange-400 underline"
              target="_blank"
              rel="noreferrer"
            >
              revenuecat.com/privacy
            </a>
            .
          </li>
        </ul>
      </Section>

      <Section heading="Sharing and tracking">
        <p>
          We do not sell your personal data, and we do not use it for
          cross-app advertising or tracking. Data is shared only with the
          processors above, strictly to operate the app.
        </p>
      </Section>

      <Section heading="Data retention &amp; deletion">
        <p>
          Your profile and training data live on your device and remain until you
          delete it in the app or uninstall the app. Subscription records held by
          Apple and RevenueCat are retained according to their policies. To
          request deletion of any data we hold, see{" "}
          <a href="/privacy-choices" className="font-semibold text-orange-400 underline">
            Privacy Choices
          </a>
          .
        </p>
      </Section>

      <Section heading="Children">
        <p>
          Kyrie AI is intended for a general audience. It is not directed to
          children under 13, and we do not knowingly collect personal data from
          children under 13. If you believe a child has provided us data, contact
          us and we will remove it.
        </p>
      </Section>

      <Section heading="International transfers">
        <p>
          Our service providers may process limited data (such as subscription
          status) on servers located outside your country. They maintain
          safeguards consistent with applicable law.
        </p>
      </Section>

      <Section heading="Changes to this policy">
        <p>
          We may update this policy from time to time. Material changes will be
          reflected by updating the effective date above.
        </p>
      </Section>

      <Section heading="Contact">
        <p>
          Questions? Email{" "}
          <a href={`mailto:${SUPPORT_EMAIL}`} className="font-semibold text-orange-400 underline">
            {SUPPORT_EMAIL}
          </a>
          .
        </p>
      </Section>
    </LegalLayout>
  );
};

export default Privacy;
