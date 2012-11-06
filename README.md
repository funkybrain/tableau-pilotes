## Change Log:

**30/08/2012**
* added some (very) basic UI
* debrief mission can now accept multiple claims, separate from mission debrief itself.
Not surprisingly, by implementing this flexibility I opened a can of worms , but, eh, it seems to work.

**27/08/2012**
* added sinatra/reloader
* refactored admin/mission to use Ajax
* bugfixing

## To Do:
* add flags for campagne en cours et nations jouées pour filtrer tout ce qui est lié à une nationalité
* fix horrible hack on the temps_vol db submission
* tighten requirements on Model fields once it is clear what is/isn't absolutely required
* validate (regex) all text input fields
* figure out why I can't just use flight_id PK in FlightResults, instead of all of Flight CK...
* find eloquent way to add revendications dynamically
* add image fields for all the nifty icons (medailles, etc)
* use jQ sortable tables plug-in

## Dev Notes:
* DM associations can be tricky. Use belongs_to when you want to put a foreign key in a table
e.g. in Grade table -  'belongs_to :nation' will add an 'id_nation' f key in the Grade table. That's counter(my)intuition :/
* Table_1 has n Table_2 will create a Table_1.id fk in Table 2
* Don't forget to plurialize one-to-many associations, e.g. has n, :grades and NOT grade
* datamapper tried to plurialize 'Sortie' as 'Sorty' and not 'Sorties', hence the clusterfuck.
* use underscore to plurialize models with camel case: FlightResult =* :flight_results
* carefull with Model.All, you'll get a collection (array) back. Use Model.first if you want to be able to get a model property easily.
* It you return a nil obect (record) when querying, trying to access a property (field) of that object will give you an error!

## (Archive) Change Log:
**21/08/2012**
* A lot of refactoring and cleaning up of app and models
* added session parameters for campagne en cours and pilote to simulate login (temp)
* solved char encoding. Had to friggin set the encoding under the editor to utf-8 (via r-click properties... wtf!)

**20/08/12**
* Mise en place de l'attribution des medailles et citations par l'admin
... j'en ai chié, on aborde les relations plus complexes et les problemes d'objets vides à gérer.

**19/08/12**
* Formulaire des pilotes complet et à peu près fonctionel (une seule revendication pour l'instant)
* une soupçon de mise en forme pour rendre la lecture pus facile
