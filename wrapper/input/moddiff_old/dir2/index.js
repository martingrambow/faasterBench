const nodemailer6 = require("nodemailer6");

//entry subject
//entry to
//entry textInput

let options = 
{
    smtpServer:"smtp.ethereal.email", 
    from: "geraldine.simonis67@ethereal.email",
    to: to,
    subject: subject,
    text: textInput
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

const transporter = nodemailer6.createTransport({
  host: 'smtp.ethereal.email',
  port: 587,
  auth: {
      user: 'geraldine.simonis67@ethereal.email',
      pass: 'rGgzdcrHdC7nQBPp5Z'
  }
});

let info = await transporter.sendMail({
  from: options.from, // sender address
  to: options.to, // list of receivers
  subject: options.subject, // Subject line
  text: options.textInput, // plain text body
});

console.log("Sent message");
  // Message sent: <b658f8ca-6296-ccf4-8306-87d57a0b4321@example.com>

return extTime;