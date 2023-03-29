The below command prints the information for all explicitly installed packages,
and then greps their names and descriptions. This grepped text is then formatted
by sed to get rid of the "Name" and "Description" labels and keep the remaining
information on its own line. Then it directs all this into a new text file.

    $ yay -Qei | grep 'Name\|Description' | sed 'N;s/\n/ /;s/Name            : //;s/Description     //' > package-info.txt

The below command does a very similar thing to the above, except it looks for a
package called PACKAGE_NAME in the installed explicitly installed packages and
appends the information to the package-info.txt file instead of overwriting it.

    $ yay -Qei | grep 'Name            : PACKAGE_NAME' -A 20 | grep 'Name\|Description' | sed 'N;s/\n/ /;s/Name            : //;s/Description     //' >> packages.txt