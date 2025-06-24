package mailer

import (
	"fmt"

	"gopkg.in/mail.v2"
	gomail "gopkg.in/mail.v2"
)

type Mailer struct {
	dialer *gomail.Dialer
	from   string
}

func NewMailer(host string, port int, username, password, from string) *Mailer {
	d := gomail.NewDialer(host, port, username, password)
	return &Mailer{
		dialer: d,
		from:   from,
	}
}

func (m *Mailer) SendResetPassword(to, code string) error {
	msg := mail.NewMessage()
	msg.SetHeader("From", m.from)
	msg.SetHeader("To", to)
	msg.SetHeader("Subject", "Password Reset Request")

	body := fmt.Sprintf("Your password reset code is: %s\n\n"+
		"This code will expire in 15 minutes. Enter it in the app to reset your password.", code)

	msg.SetBody("text/plain", body)
	return m.dialer.DialAndSend(msg)
}
