<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0" xmlns:mods="http://www.loc.gov/mods/v3">
  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
  <!--Purpose: make Orlando Legacy to MODS documents editable in the CWRC XML forms on cwrc.ca -->
  
  <!--copy everything as in source document unless otherwise instructed below in this xslt -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- strip space -->
  <xsl:strip-space elements="*"/>
  
  <!-- ensure any MODS document has mods as the root element -->
  <xsl:template match="/">
    <mods 
      xmlns="http://www.loc.gov/mods/v3"
      xmlns:tei="http://www.tei-c.org/ns/1.0"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xmlns:orl="http://ualberta.ca/orlando" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd"
      version="3.4"><xsl:apply-templates select="//mods:mods/*"/></mods></xsl:template>
</xsl:stylesheet>
