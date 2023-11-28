import nodemailer from 'nodemailer6';

let options = 
{
    smtpServer:"smtp-relay.brevo.com", 
    username: process.env.user, 
    password: process.env.password, 
    from: "gov23@brevo.com",
    to: "gov23receiver@brevo.com",
    subject: "Benchmark",
    text: "Benchmark text, you will receive this mail multiple times"
};
/**
 * @summary Send an email. Throws an `Error` on failure to contact mail server
 * or if mail server returns an error. All fields should match
 * [RFC5322](http://tools.ietf.org/html/rfc5322) specification.
 *
 * If the `MAIL_URL` environment variable is set, actually sends the email.
 * Otherwise, prints the contents of the email to standard out.
 *
 * Note that this package is based on **nodemailer**, so make sure to refer to
 * [the documentation](http://nodemailer.com/)
 * when using the `attachments` or `mailComposer` options.
 *
 * @param {Object} options
 * @param {String} [options.from] "From:" address (required)
 * @param {String|String[]} options.to,cc,bcc,replyTo
 *   "To:", "Cc:", "Bcc:", and "Reply-To:" addresses
 * @param {String} [options.subject]  "Subject:" line
 * @param {String} [options.text|html] Mail body (in plain text and/or HTML)
 */

let transporter = nodemailer.createTransport({
    host: "",
    port: 587,
    secure: false, // true for 465, false for other ports
    auth: {
      user: process.env.user, // generated brevo user
      pass: process.env.password, // generated brevo password
    },
  });

for(var i = 0; i < 100; i++){
  let info = transporter.sendMail({
    from: options.from, // sender address
    to: options.to, // list of receivers
    subject: options.subject, // Subject line
    text: options.text, // plain text body
  });

  console.log("Message sent: %s", info.messageId);
  // Message sent: <b658f8ca-6296-ccf4-8306-87d57a0b4321@example.com>
}