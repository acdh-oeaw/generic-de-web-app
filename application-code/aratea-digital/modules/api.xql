xquery version "3.0";

module namespace api="http://www.digital-archiv.at/ns/aratea-digital/api";
declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace functx = "http://www.functx.com";
import module namespace app="http://www.digital-archiv.at/ns/aratea-digital/templates" at "app.xql";
import module namespace config="http://www.digital-archiv.at/ns/aratea-digital/config" at "config.xqm";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace http = "http://expath.org/ns/http-client";

declare variable $api:JSON := 
<rest:response>
    <http:response>
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="application/json; charset=utf-8"/>
    </http:response>
    <output:serialization-parameters>
    <output:method value='json'/>
      <output:media-type value='application/json'/>
    </output:serialization-parameters>
 </rest:response>;

declare variable $api:XML := 
<rest:response>
    <http:response>
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="application/xml; charset=utf-8"/>
    </http:response>
    <output:serialization-parameters>
    <output:method value='xml'/>
      <output:media-type value='application/xml'/>
    </output:serialization-parameters>
 </rest:response>;


(:~ lists content of collection ~:)
declare 
    %rest:GET
    %rest:path("/aratea-digital/{$collection}/{$format}")
function api:list-documents($collection, $format) {
let $result:= api:list-collection-content($collection)

let $serialization := switch($format)
    case('xml') return $api:XML
    default return $api:JSON
        return 
            ($serialization, $result)
};

declare 
    %rest:GET
    %rest:path("/aratea-digital/{$collection}/{$id}/{$format}")
function api:show-document-api($collection, $id, $format) {
    let $result := api:show-document($collection, $id)
    let $serialization := switch($format)
    case('xml') return $api:XML
    default return $api:JSON
    return 
       ($serialization, $result)
};


declare %private function api:list-collection-content($collection as xs:string){
    let $result:= 
        <result>
            {for $doc in collection($config:app-root||'/data/'||$collection)//tei:TEI
            let $path := functx:substring-before-last(document-uri(root($doc)),'/')
            let $id := app:getDocName($doc)
                return
                <entry>
                    <ID>{$id}</ID>
                    <path>{$path}</path>
                    <created>{xmldb:created($path, $id)}</created>
                    <modified>{xmldb:last-modified($path, $id)}</modified>
                </entry>
             }
        </result>
        return 
            $result
};

declare %private function api:show-document($collection as xs:string, $id as xs:string){
    let $doc := doc($config:app-root||'/data/'||$collection||'/'||$id)
    return 
        <result>
            <somethingFound>
                {$doc}
            </somethingFound>
        </result>
};