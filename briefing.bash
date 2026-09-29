cd vreme
echo "VREME: "
(bash nasvet.bash; sleep 30) & 
echo $!
cd ..
cd novice
echo "NOVICE: "
(bash novice.bash; sleep 30) & 
echo $!
cd ..
