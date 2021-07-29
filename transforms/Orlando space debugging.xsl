<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:output encoding="UTF-8" method="xml" indent="no"/>
  
  <!--copy everything as in source document unless otherwise instructed below in this xslt -->
  <xsl:template match="@*|*|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- strip space -->
  <xsl:strip-space elements="*"/>
  
  
  <xsl:template match="*[parent::CHRONPROSE|parent::CHRONSTRUCT|parent::P|parent::HEADING|parent::MARRIAGE|parent::CORR|parent::MARRIED|parent::RELIGIOUSNAME|parent::ROYAL|parent::STYLED|parent::SURNAME|parent::TITLED|parent::ADDRESS|parent::ADDRLINE|parent::AREA|parent::AWARD|parent::BIBCIT|parent::BIBCITS|parent::BIRTHNAME|parent::BIRTHPOSITION|parent::CAUSE|parent::CHILDLESSNESS|parent::CHILDREN|parent::CLASS|parent::COMPANION|parent::CONTESTEDBEHAVIOUR|parent::DATE|parent::DAY|parent::DEGREE|parent::DENOMINATION|parent::DIVORCE|parent::EMPH|parent::EMPLOYER|parent::ETHNICITY|parent::EXTENTOFOEUVRE|parent::FOREIGN|parent::GENERICRANGE|parent::GEOG|parent::GEOGHERITAGE|parent::GIVEN|parent::HEAD|parent::INDEXED|parent::INSTRUCTOR|parent::JOB|parent::KEYWORDCLASS|parent::L|parent::LANGUAGE|parent::LB|parent::LG|parent::LIVESWITH|parent::MONTH|parent::NAME|parent::NATIONALHERITAGE|parent::NATIONALITY|parent::NICKNAME|parent::OCCASION|parent::ORGNAME|parent::PADVERTISING|parent::PANTHOLOGIZATION|parent::PARCHIVALLOCATION|parent::PATTITUDES|parent::PAUTHORSHIP|parent::PCIRCULATION|parent::PCONTRACT|parent::PCOPYRIGHT|parent::PDEDICATION|parent::PEARNINGS|parent::PEDITIONS|parent::PFIRSTLITERARYACTIVITY|parent::PINFLUENCESHER|parent::PLACE|parent::PLACENAME|parent::PLASTLITERARYACTIVITY|parent::PLITERARYSCHOOLS|parent::PMANUSCRIPTHISTORY|parent::PMATERIALCONDITIONS|parent::PMODEOFPUBLICATION|parent::PMOTIVES|parent::PNONBOOKMEDIA|parent::PNONSURVIVAL|parent::POLITICALAFFILIATION|parent::PPERFORMANCE|parent::PPERIODICALPUBLICATION|parent::PPLACEOFPUBLICATION|parent::PPRESSRUN|parent::PPRICE|parent::PRARITIESFEATURESDECORATIONS|parent::PRELATIONSWITHPUBLISHER|parent::PSERIALIZATION|parent::PSEUDONYM|parent::PSUBMISSIONSREJECTIONS|parent::PTYPEOFPRESS|parent::QUOTE|parent::RACECOLOUR|parent::RBESTKNOWNWORK|parent::RDESTRUCTIONOFWORK|parent::REGION|parent::REMUNERATION|parent::RFICTIONALIZATION|parent::RLANDMARKTEXT|parent::RPENALTIES|parent::RRECOGNITIONNAME|parent::RRECOGNITIONS|parent::RRECOGNITIONVALUE|parent::RESPONSES|parent::RS|parent::RSELFDESCRIPTION|parent::RSHEINFLUENCED|parent::RWRITINGMILESTONE|parent::SCHOLARNOTE|parent::SCHOOL|parent::SEASON|parent::SELFCONSTRUCTED|parent::SEPARATION|parent::SETTLEMENT|parent::SEXUALIDENTITY|parent::SIC|parent::SIGNIFICANTACTIVITY|parent::SOCALLED|parent::SUBJECT|parent::TCHARACTERIZATION|parent::TCHARACTERNAME|parent::TCHARACTERTYPEROLE|parent::TEXT|parent::TGENRE|parent::TGENREISSUE|parent::TIME|parent::TINTERTEXTUALITY|parent::TITLE|parent::TMOTIF|parent::TOPIC|parent::TPLOT|parent::TSETTINGDATE|parent::TSETTINGPLACE|parent::TTECHNIQUES|parent::TTHEMETOPIC|parent::TTONESTYLE|parent::TVOICENARRATION|parent::WEEK|parent::XREF|parent::YEAR]">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    <xsl:choose>
      <!--<xsl:when test="following-sibling::node()[position()=1 and ./descendant::*[text()]]">
        <xsl:text>+</xsl:text>
      </xsl:when>
      <xsl:when test="following-sibling::node()[position()=1 and not(self::text())]">
        <xsl:text>++</xsl:text>
      </xsl:when>
      <xsl:when test="following-sibling::node()[position()=1 and (not(self::text()) and not(./descendant::*[text()]) )]">
        <xsl:text>+++</xsl:text>-->
      <!--</xsl:when>-->
      <xsl:when test="following-sibling::node()[position()=1][not(self::text()) and ./descendant-or-self::*[text()]]">
        <xsl:text> </xsl:text>
      </xsl:when>
    </xsl:choose>   
  </xsl:template>
  
  <xsl:template match="text()">
    <xsl:value-of select="replace(., '¥', '£')"/>
  </xsl:template>
  
  
</xsl:stylesheet>
