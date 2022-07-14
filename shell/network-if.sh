function interface-release-IP {
  dhclient -v -r $1
}

function interface-request-IP {
  dhclient -v $1
}


#https://gist.github.com/extremecoders-re/e8fd8a67a515fee0c873dcafc81d811c
