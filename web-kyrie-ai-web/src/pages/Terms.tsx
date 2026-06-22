import LegalLayout, { Section } from "@/components/LegalLayout";

const SUPPORT_EMAIL = "olivernasatir@gmail.com";
const EFFECTIVE_DATE = "June 7, 2026";

const Terms = () => {
  return (
    <LegalLayout title="Terms of Use">
      <p className="text-sm text-zinc-500">Effective date: {EFFECTIVE_DATE}</p>

      <p>
        These Terms of Use ("Terms") govern your use of the{" "}
        <strong>Kyrie AI Dribble Trainer</strong> iOS app ("Kyrie AI", the
        "app"). By downloading or using the app, you agree to these Terms.
      </p>

      <Section heading="License">
        <p>
          We grant you a personal, non-exclusive, non-transferable, revocable
          license to use Kyrie AI for your own non-commercial training, subject to
          these Terms.
        </p>
      </Section>

      <Section heading="Acceptable use">
        <ul className="list-disc space-y-1 pl-6">
          <li>Don't copy, reverse engineer, or resell the app.</li>
          <li>Don't use the app for any unlawful purpose.</li>
          <li>Don't attempt to disrupt or circumvent app security or paywalls.</li>
        </ul>
      </Section>

      <Section heading="Subscriptions &amp; purchases">
        <p>
          Kyrie AI Pro is an auto-renewing subscription offered in monthly and
          yearly plans. The yearly plan includes a 3-day free trial for eligible
          new subscribers.
        </p>
        <ul className="list-disc space-y-1 pl-6">
          <li>
            Payment is charged to your Apple ID at confirmation of purchase.
          </li>
          <li>
            Subscriptions renew automatically unless cancelled at least 24 hours
            before the end of the current period.
          </li>
          <li>
            Your account is charged for renewal within 24 hours before the end of
            the current period.
          </li>
          <li>
            If a free trial is offered, any unused portion is forfeited when you
            purchase a subscription.
          </li>
          <li>
            Manage or cancel anytime in iOS Settings → your name → Subscriptions.
          </li>
          <li>
            Refunds are handled by Apple at{" "}
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

      <Section heading="Health &amp; safety disclaimer">
        <p>
          Kyrie AI provides training drills and coaching guidance for
          informational purposes only. It is not medical or professional fitness
          advice. Train within your limits, warm up properly, and consult a
          physician before beginning any new physical activity. You use the app at
          your own risk.
        </p>
      </Section>

      <Section heading="AI-generated guidance">
        <p>
          Training plans, scores, and feedback are generated automatically and may
          be imperfect. They are suggestions, not guarantees of any specific
          athletic result.
        </p>
      </Section>

      <Section heading="Service availability">
        <p>
          We may update, change, or discontinue features at any time. We are not
          liable for any interruption or loss of data stored on your device.
        </p>
      </Section>

      <Section heading="Termination">
        <p>
          You may stop using the app at any time. We may suspend or terminate
          access if you violate these Terms.
        </p>
      </Section>

      <Section heading="Disclaimer &amp; limitation of liability">
        <p>
          The app is provided "as is" without warranties of any kind. To the
          fullest extent permitted by law, we are not liable for any indirect,
          incidental, or consequential damages arising from your use of the app.
        </p>
      </Section>

      <Section heading="Contact">
        <p>
          Questions about these Terms? Email{" "}
          <a href={`mailto:${SUPPORT_EMAIL}`} className="font-semibold text-orange-400 underline">
            {SUPPORT_EMAIL}
          </a>
          .
        </p>
      </Section>
    </LegalLayout>
  );
};

export default Terms;
