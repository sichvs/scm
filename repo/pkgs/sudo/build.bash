pkg install sudo -y
mkdir -p $HOME/.cache; touch binary-superuser-lts; cat $PREFIX/bin/sudo > binary-superuser-lts
chmod a+x $HOME/.cache/binary-superuser-lts
