#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright Clairvoyant 2015

DOMAIN1=com
DOMAIN2=clairvoyantsoft
ROOTDN="cn=Manager,dc=${DOMAIN2},dc=${DOMAIN1}"
ROOTPW=password
LDAPPASS=`slappasswd -s $ROOTPW`

#ldapadd -x -w $ROOTPW -D $ROOTDN -H ldapi:/// <<EOF
#dn: dc=${DOMAIN2},dc=${DOMAIN1}
#objectClass: dcObject
#objectClass: organization
#dc: $DOMAIN2
#o: $DOMAIN2
#structuralObjectClass: organization
#EOF

ldapadd -x -w $ROOTPW -D $ROOTDN -H ldapi:/// <<EOF
# Creates a base for DIT
dn: dc=${DOMAIN2},dc=${DOMAIN1}
objectClass: top
objectClass: dcObject
objectclass: organization
o: $DOMAIN2
dc: $DOMAIN2
description: $DOMAIN2

dn: $ROOTDN
objectclass: organizationalRole
cn: Manager

# Creates a People OU (Organizational Unit)
dn: ou=People,dc=${DOMAIN2},dc=${DOMAIN1}
objectClass: organizationalUnit
ou: People

# Creates a Groups OU
dn: ou=Groups,dc=${DOMAIN2},dc=${DOMAIN1}
objectClass: organizationalUnit
ou: Groups
EOF

ldapadd -x -w $ROOTPW -D $ROOTDN -H ldapi:/// <<EOF
dn: uid=user00,ou=People,dc=${DOMAIN2},dc=${DOMAIN1}
uid: user00
cn: User 00
givenName: User
sn: 00
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
loginShell: /bin/bash
homeDirectory: /home/user00
uidNumber: 15000
gidNumber: 10000
userPassword: ${LDAPPASS}
mail: user00@${DOMAIN2}.${DOMAIN1}
gecos: user00 User

dn: uid=user01,ou=People,dc=${DOMAIN2},dc=${DOMAIN1}
uid: user01
cn: User 01
givenName: User
sn: 01
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
loginShell: /bin/bash
homeDirectory: /home/user01
uidNumber: 15001
gidNumber: 10001
userPassword: ${LDAPPASS}
mail: user01@${DOMAIN2}.${DOMAIN1}
gecos: user01 User

dn: uid=user02,ou=People,dc=${DOMAIN2},dc=${DOMAIN1}
uid: user02
cn: User 02
givenName: User
sn: 02
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
loginShell: /bin/bash
homeDirectory: /home/user02
uidNumber: 15002
gidNumber: 10002
userPassword: ${LDAPPASS}
mail: user02@${DOMAIN2}.${DOMAIN1}
gecos: user02 User

dn: cn=group00,ou=Groups,dc=${DOMAIN2},dc=${DOMAIN1}
objectClass: posixGroup
objectClass: top
cn: group00
userPassword: {crypt}x
gidNumber: 10000
memberuid: uid=user00

dn: cn=group01,ou=Groups,dc=${DOMAIN2},dc=${DOMAIN1}
objectClass: posixGroup
objectClass: top
cn: group01
userPassword: {crypt}x
gidNumber: 10001
memberuid: uid=user01

dn: cn=group02,ou=Groups,dc=${DOMAIN2},dc=${DOMAIN1}
objectClass: groupOfNames
member: uid=user02,ou=People,dc=${DOMAIN2},dc=${DOMAIN1}
cn: group02
EOF

ldapsearch -x -D $ROOTDN -w $ROOTPW

if [ -x /usr/sbin/kadmin.local ]; then
  kadmin.local <<EOF
addprinc -pw p@ssw0rd user00
addprinc -pw p@ssw0rd user01
addprinc -pw p@ssw0rd user02
EOF
  echo
fi

exit 0
