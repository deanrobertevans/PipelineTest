require(mailR)
### Test


send.mail(from = "pipeline@deanrobertevans.ca",
          to = c("devans@birdscanada.org"),
          subject = "KBA Canada Pipeline",
          body = "This is a test",
          smtp = list(host.name = "live.smtp.mailtrap.io", port = 587,
                      user.name = "api",
                      passwd = Sys.getenv("MAILTRAP_PASS"), ssl = TRUE),
          authenticate = TRUE,
          send = TRUE)



