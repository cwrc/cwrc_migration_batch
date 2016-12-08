<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    
    <!-- given a date in MLA format, 25 January 2019, convert to the iso representation YYYY-MM-DD -->
    <xsl:template name="convert_mla_to_iso">
        <xsl:param name="INPUT_DATE"/>
        
        <xsl:choose>
            <!-- next 12, dd month yyyy, of this form, could try to optimise -->
            <xsl:when test="contains($INPUT_DATE,'January')">
                <xsl:variable name="year"
                    select="format-number(number(normalize-space(substring-after($INPUT_DATE,'January'))),'0000')"/>
                <xsl:if test="$year!='NaN'">
                    <xsl:value-of select="$year"/>
                </xsl:if>
                <xsl:text>-01-</xsl:text>
                <xsl:variable name="day"
                    select="format-number(number(substring-before($INPUT_DATE,' ')),'00')"/>
                <xsl:if test="$day!='NaN'">
                    <xsl:value-of select="$day"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($INPUT_DATE,'February')">
                <xsl:variable name="year"
                    select="format-number(number(normalize-space(substring-after($INPUT_DATE,'February'))),'0000')"/>
                <xsl:if test="$year!='NaN'">
                    <xsl:value-of select="$year"/>
                </xsl:if>
                <xsl:text>-02-</xsl:text>
                <xsl:variable name="day"
                    select="format-number(number(substring-before($INPUT_DATE,' ')),'00')"/>
                <xsl:if test="$day!='NaN'">
                    <xsl:value-of select="$day"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($INPUT_DATE,'March')">
                <xsl:variable name="year"
                    select="format-number(number(normalize-space(substring-after($INPUT_DATE,'March'))),'0000')"/>
                <xsl:if test="$year!='NaN'">
                    <xsl:value-of select="$year"/>
                </xsl:if>
                <xsl:text>-03-</xsl:text>
                <xsl:variable name="day"
                    select="format-number(number(substring-before($INPUT_DATE,' ')),'00')"/>
                <xsl:if test="$day!='NaN'">
                    <xsl:value-of select="$day"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($INPUT_DATE,'April')">
                <xsl:variable name="year"
                    select="format-number(number(normalize-space(substring-after($INPUT_DATE,'April'))),'0000')"/>
                <xsl:if test="$year!='NaN'">
                    <xsl:value-of select="$year"/>
                </xsl:if>
                <xsl:text>-04-</xsl:text>
                <xsl:variable name="day"
                    select="format-number(number(substring-before($INPUT_DATE,' ')),'00')"/>
                <xsl:if test="$day!='NaN'">
                    <xsl:value-of select="$day"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($INPUT_DATE,'May')">
                <xsl:variable name="year"
                    select="format-number(number(normalize-space(substring-after($INPUT_DATE,'May'))),'0000')"/>
                <xsl:if test="$year!='NaN'">
                    <xsl:value-of select="$year"/>
                </xsl:if>
                <xsl:text>-05-</xsl:text>
                <xsl:variable name="day"
                    select="format-number(number(substring-before($INPUT_DATE,' ')),'00')"/>
                <xsl:if test="$day!='NaN'">
                    <xsl:value-of select="$day"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($INPUT_DATE,'June')">
                <xsl:variable name="year"
                    select="format-number(number(normalize-space(substring-after($INPUT_DATE,'June'))),'0000')"/>
                <xsl:if test="$year!='NaN'">
                    <xsl:value-of select="$year"/>
                </xsl:if>
                <xsl:text>-06-</xsl:text>
                <xsl:variable name="day"
                    select="format-number(number(substring-before($INPUT_DATE,' ')),'00')"/>
                <xsl:if test="$day!='NaN'">
                    <xsl:value-of select="$day"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($INPUT_DATE,'July')">
                <xsl:variable name="year"
                    select="format-number(number(normalize-space(substring-after($INPUT_DATE,'July'))),'0000')"/>
                <xsl:if test="$year!='NaN'">
                    <xsl:value-of select="$year"/>
                </xsl:if>
                <xsl:text>-07-</xsl:text>
                <xsl:variable name="day"
                    select="format-number(number(substring-before($INPUT_DATE,' ')),'00')"/>
                <xsl:if test="$day!='NaN'">
                    <xsl:value-of select="$day"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($INPUT_DATE,'August')">
                <xsl:variable name="year"
                    select="format-number(number(normalize-space(substring-after($INPUT_DATE,'August'))),'0000')"/>
                <xsl:if test="$year!='NaN'">
                    <xsl:value-of select="$year"/>
                </xsl:if>
                <xsl:text>-08-</xsl:text>
                <xsl:variable name="day"
                    select="format-number(number(substring-before($INPUT_DATE,' ')),'00')"/>
                <xsl:if test="$day!='NaN'">
                    <xsl:value-of select="$day"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($INPUT_DATE,'September')">
                <xsl:variable name="year"
                    select="format-number(number(normalize-space(substring-after($INPUT_DATE,'September'))),'0000')"/>
                <xsl:if test="$year!='NaN'">
                    <xsl:value-of select="$year"/>
                </xsl:if>
                <xsl:text>-09-</xsl:text>
                <xsl:variable name="day"
                    select="format-number(number(substring-before($INPUT_DATE,' ')),'00')"/>
                <xsl:if test="$day!='NaN'">
                    <xsl:value-of select="$day"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($INPUT_DATE,'October')">
                <xsl:variable name="year"
                    select="format-number(number(normalize-space(substring-after($INPUT_DATE,'October'))),'0000')"/>
                <xsl:if test="$year!='NaN'">
                    <xsl:value-of select="$year"/>
                </xsl:if>
                <xsl:text>-10-</xsl:text>
                <xsl:variable name="day"
                    select="format-number(number(substring-before($INPUT_DATE,' ')),'00')"/>
                <xsl:if test="$day!='NaN'">
                    <xsl:value-of select="$day"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($INPUT_DATE,'November')">
                <xsl:variable name="year"
                    select="format-number(number(normalize-space(substring-after($INPUT_DATE,'November'))),'0000')"/>
                <xsl:if test="$year!='NaN'">
                    <xsl:value-of select="$year"/>
                </xsl:if>
                <xsl:text>-11-</xsl:text>
                <xsl:variable name="day"
                    select="format-number(number(substring-before($INPUT_DATE,' ')),'00')"/>
                <xsl:if test="$day!='NaN'">
                    <xsl:value-of select="$day"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="contains($INPUT_DATE,'December')">
                <xsl:variable name="year"
                    select="format-number(number(normalize-space(substring-after($INPUT_DATE,'December'))),'0000')"/>
                <xsl:if test="$year!='NaN'">
                    <xsl:value-of select="$year"/>
                </xsl:if>
                <xsl:text>-12-</xsl:text>
                <xsl:variable name="day"
                    select="format-number(number(substring-before($INPUT_DATE,' ')),'00')"/>
                <xsl:if test="$day!='NaN'">
                    <xsl:value-of select="$day"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <!-- use text of the tag e.g. 1942 and concat 2 '-'  -->
                <xsl:value-of select="concat($INPUT_DATE,'--')"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    
    <!-- given a date in ISo format, YYYY-MM-DD, convert to the MLA character representation -->
    <xsl:template name="convert_iso_to_mla">
        <xsl:param name="INPUT_DATE"/>
        
        <xsl:if test="$INPUT_DATE and string-length($INPUT_DATE) > 0">
            <xsl:variable name="tokenized_date" select="tokenize($INPUT_DATE,'-')"/>
            <!-- output "dd month yyyy" -->
            <xsl:value-of select="$tokenized_date[3]"/>
            <xsl:text> </xsl:text>
            <xsl:call-template name="convert_numbered_month_to_character">
                <xsl:with-param name="INPUT_NUMERIC_MONTH" select="$tokenized_date[2]"/>
            </xsl:call-template>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$tokenized_date[1]"/>
        </xsl:if>
        
    </xsl:template>
    
    
    
    <!-- given a month, MM in 2 digit format, convert to the character representation -->
    <xsl:template name="convert_numbered_month_to_character">
        <xsl:param name="INPUT_NUMERIC_MONTH"/>
        
        <xsl:choose>
            <xsl:when test="$INPUT_NUMERIC_MONTH='01'">
                <xsl:text>January</xsl:text>
            </xsl:when>
            <xsl:when test="$INPUT_NUMERIC_MONTH='02'">
                <xsl:text>February</xsl:text>
            </xsl:when>
            <xsl:when test="$INPUT_NUMERIC_MONTH='03'">
                <xsl:text>March</xsl:text>
            </xsl:when>
            <xsl:when test="$INPUT_NUMERIC_MONTH='04'">
                <xsl:text>April</xsl:text>
            </xsl:when>
            <xsl:when test="$INPUT_NUMERIC_MONTH='05'">
                <xsl:text>May</xsl:text>
            </xsl:when>
            <xsl:when test="$INPUT_NUMERIC_MONTH='06'">
                <xsl:text>June</xsl:text>
            </xsl:when>
            <xsl:when test="$INPUT_NUMERIC_MONTH='07'">
                <xsl:text>July</xsl:text>
            </xsl:when>
            <xsl:when test="$INPUT_NUMERIC_MONTH='08'">
                <xsl:text>August</xsl:text>
            </xsl:when>
            <xsl:when test="$INPUT_NUMERIC_MONTH='09'">
                <xsl:text>September</xsl:text>
            </xsl:when>
            <xsl:when test="$INPUT_NUMERIC_MONTH='10'">
                <xsl:text>October</xsl:text>
            </xsl:when>
            <xsl:when test="$INPUT_NUMERIC_MONTH='11'">
                <xsl:text>November</xsl:text>
            </xsl:when>
            <xsl:when test="$INPUT_NUMERIC_MONTH='12'">
                <xsl:text>December</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>XXXXX</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
    
    
    
</xsl:stylesheet>