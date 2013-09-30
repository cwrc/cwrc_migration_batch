<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="2.0"
  >

  <!--
  * given a CWRC entity - person, org, place
  * output a DC format  
  -->

  <xsl:output encoding="UTF-8" method="xml" indent="yes" omit-xml-declaration="no" />


  <!--
  * PID value passed into the transform 
  -->
  <xsl:param name="PID_PARAM" value="zzzz" />


  <!--
  * build DC
  -->
  <xsl:template match="/cwrc/entity | /mods:modsCollection/mods:mods">
    <oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd" >
      <dc:title>
        <xsl:call-template name="GET_DC_TITLE" />
      </dc:title>
      <dc:identifier>
        <xsl:value-of select="$PID_PARAM" />
      </dc:identifier>
    </oai_dc:dc> 
  </xsl:template>


  <!--
  * build the DC title - Person Entity
  -->
  <xsl:template name="GET_DC_TITLE">

    <xsl:choose>
      <xsl:when test="entity/person">
        <xsl:call-template name="GET_DC_TITLE-ENTITY_PERSON" />
      </xsl:when>
      <xsl:when test="entity/organization">
        <xsl:call-template name="GET_DC_TITLE-ENTITY_ORGANIZATION" />
      </xsl:when>
      <xsl:when test="mods:mods">
        <xsl:call-template name="GET_DC_TITLE-ENTITY_TITLE" />
      </xsl:when>
      <xsl:otherwise> 
        <xsl:text>zzzz ERROR unknown Type</xsl:text>
      </xsl:otherwise >
    </xsl:choose>

  </xsl:template>


  <!--
  * build the DC title - person entity
  * privelege preferredForm/displayLabel 
  * over the preferredForm/givenName concatenated with the preferredForm/Surname
  * over the preferredForm/namePart
  -->
  <xsl:template name="GET_DC_TITLE-ENTITY_PERSON">

    <xsl:choose>
      <!-- displayLabel -->
      <xsl:when test="identity/displayLabel">
        <xsl:value-of select="identity/displayLabel" />
      </xsl:when>
      <!-- givenName and surName -->
      <xsl:when test="identity/preferredForm/namePart/@surname || identity/preferredForm/namePart/@givenName">
        <xsl:if test="identity/preferredForm/namePart/@surname">
          <xsl:value-of select="identity/preferredForm/namePart[type='surname']" />
        </xsl:if>
        <xsl:if test="identity/preferredForm/namePart/@surname && identity/preferredForm/namePart/@givenname">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="identity/preferredForm/namePart/@givenname">
          <xsl:value-of select="identity/preferredForm/namePart[type='givenname']" />
        </xsl:if>
      </xsl:when>
      <!-- namePart -->
      <xsl:when test="identity/preferredForm/namePart">
          <xsl:value-of select="identity/preferredForm/namePart" />
      </xsl:when>
      <xsl:otherwise> 
        <xsl:text>zzzz ERROR unknown label</xsl:text>
      </xsl:otherwise >
    </xsl:choose>
  </xsl:template>


  <!--
  * build the DC title - organisation entity
  * privelege preferredForm/displayLabel over the preferredForm/namePart
  -->
  <xsl:template name="GET_DC_TITLE-ENTITY_ORGANISATION">

    <xsl:choose>
      <!-- displayLabel -->
      <xsl:when test="identity/displayLabel">
        <xsl:value-of select="identity/displayLabel" />
      </xsl:when>
      <!-- namePart -->
      <xsl:when test="identity/preferredForm/namePart">
          <xsl:value-of select="identity/preferredForm/namePart" />
      </xsl:when>
      <xsl:otherwise> 
        <xsl:text>zzzz ERROR unknown label</xsl:text>
      </xsl:otherwise >
    </xsl:choose>
  </xsl:template>


  <!--
  * build the DC title - Title entity
  -->
  <xsl:template name="GET_DC_TITLE-ENTITY_TITLE">
    <xsl:value-of select="mods:titleInfo/mods:title"/>
  </xsl:template>

</xsl:stylesheet>
