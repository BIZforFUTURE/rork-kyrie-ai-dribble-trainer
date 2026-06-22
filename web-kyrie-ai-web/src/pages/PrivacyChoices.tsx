import LegalLayout, { Section } from "@/components/LegalLayout";

const SUPPORT_EMAIL = "olivernasatir@gmail.com";

const PrivacyChoices = () => {
  return (
    <LegalLayout title="Privacy Choices">
      <p>
        You're in control of your data in{" "}
        <strong>Kyrie AI Dribble Trainer</strong>. Here's how to exercise your
        choices.
      </p>

      <Section heading="Delete your data">
        <p>
          Your profile and training history are stored on your device. You can
          remove them at any time by retaking the welcome quiz (which clears your
          profile) or by deleting the app from your iPhone. To request deletion of
          any subscription-related records we may hold, email us at{" "}
          <a href={`mailto:${SUPPORT_EMAIL}`} className="font-semibold text-orange-400 underline">
            {SUPPORT_EMAIL}
          </a>
          .
        </p>
      </Section>

      <Section heading="Access &amp; export your data">
        <p>
          To request a copy of any data associated with your account, email{" "}
          <a href={`mailto:${SUPPORT_EMAIL}`} className="font-semibold text-orange-400 underline">
            {SUPPORT_EMAIL}
          </a>{" "}
          with the subject "Data Request". We may ask you to verify your identity
          (for example, the Apple ID email used for purchases).
        </p>
      </Section>

      <Section heading="Manage permissions">
        <ul className="list-disc space-y-1 pl-6">
          <li>
            <strong>Camera</strong> — turn access on or off in iOS Settings →
            Kyrie AI → Camera.
          </li>
          <li>
            <strong>Notifications</strong> — manage reminders in iOS Settings →
            Kyrie AI → Notifications.
          </li>
        </ul>
      </Section>

      <Section heading="Subscriptions">
        <p>
          Manage or cancel Kyrie AI Pro in iOS Settings → your name →
          Subscriptions. Restore a previous purchase from the paywall or profile
          screen in the app.
        </p>
      </Section>

      <Section heading="Marketing">
        <p>
          We do not send marketing emails or share your data for advertising. If
          this ever changes, you'll be able to opt out here.
        </p>
      </Section>

      <Section heading="Contact">
        <p>
          For any privacy request, email{" "}
          <a href={`mailto:${SUPPORT_EMAIL}`} className="font-semibold text-orange-400 underline">
            {SUPPORT_EMAIL}
          </a>
          .
        </p>
      </Section>
    </LegalLayout>
  );
};

export default PrivacyChoices;
