<!--
The REED Project
2018-07-31: initial TEI files for ingest contained MODS metadata in the TEI header - this XSLT outputs a copy to allow 
populating the MODS datastream
-->
<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"  
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:mods="http://www.loc.gov/mods/v3" 
  version="2.0"
  >
  
  <xsl:template match="/">
    <xsl:copy-of select="/tei:TEI/tei:teiHeader/tei:xenoData/mods:mods" copy-namespaces="no" />
  </xsl:template>
  
</xsl:transform>