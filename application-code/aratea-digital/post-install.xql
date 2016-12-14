xquery version "3.0";
import module namespace config="http://www.digital-archiv.at/ns/aratea-digital/config" at "modules/config.xqm";

declare variable $app-user := "aratea-digital";

(: create 'application' group :)
if (not(sm:group-exists($app-user)))
then sm:create-group($app-user)
else (),

(: grant all rights to all documents to 'application' group:)

for $collection in xmldb:get-child-collections($config:app-root||"/data")
    let $changed := sm:add-group-ace(xs:anyURI($config:app-root||"/data/"||$collection), $app-user, true(), "rwx")
    for $resource in xmldb:get-child-resources(xs:anyURI($config:app-root||"/data/"||$collection))
        return
            sm:add-group-ace(xs:anyURI($config:app-root||"/data/"||$collection||"/"||$resource), $app-user, true(), "rwx")

(: remove access rights to import-documents-check.html for guest user :)
(:sm:chmod(xs:anyURI($config:app-root||"/pages/toc.html"), "rw-rw----"):)