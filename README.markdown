Segreto CLI
===========

## Basic Functionality

### User Management

  * seg register <username> <password> <password_confirmation>
  * seg login <username> <password>
  * seg account
    * seg account -e (--edit) <field-name*> <new-value*>
    * seg account -ep (--edit --password) <old> <new> <new-confirmation>
    * seq account --destroy (are you sure? y/n)

### Secret Management
  * seg recall <key> 
    * seg -a (--all) recall -> keys
    * seg -A (--ALL) recall -> key/secrets
  * seg remember <key> <secret>
  * seg revise (change) <key> <new-secret> (are you sure?)
  * seg forget <key> (are you sure? y/n)
