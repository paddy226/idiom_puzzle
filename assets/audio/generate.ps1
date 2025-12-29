$clickBase64 = "UklGRjIAAABXQVZFZm10IBAAAAABAAEAgD4AAIA+AAACABAAZGF0YRAAAAB7f39/f39/f39/f39/f39/f39/f39/"
$successBase64 = "UklGRjIAAABXQVZFZm10IBAAAAABAAEAgD4AAIA+AAACABAAZGF0YRAAAAB7f39/f39/f39/f39/f39/f39/f39/"
$errorBase64 = "UklGRjIAAABXQVZFZm10IBAAAAABAAEAgD4AAIA+AAACABAAZGF0YRAAAAB7f39/f39/f39/f39/f39/f39/f39/"

[IO.File]::WriteAllBytes("assets/audio/click.wav", [Convert]::FromBase64String($clickBase64))
[IO.File]::WriteAllBytes("assets/audio/success.wav", [Convert]::FromBase64String($successBase64))
[IO.File]::WriteAllBytes("assets/audio/error.wav", [Convert]::FromBase64String($errorBase64))
