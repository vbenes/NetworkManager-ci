#!/bin/env python

# Export feature file in tcms
# Parameter: export_feature_to_tcms.py <feature file>

import sys
from behave import parser as gherkin_parser
from optparse import OptionParser
import codecs
import xml.etree.ElementTree as ET


usage = "usage: %prog [options] feature_file"
parser = OptionParser(usage=usage)
parser.add_option("-o", "--output", dest="output_file",
                  help="write tcms xml to FILE", metavar="FILE")
parser.add_option("-a", "--author", dest="author",
                  help="set testcase author to AUTHOR", metavar="AUTHOR")
parser.add_option("-c", "--component", dest="component",
                  help="set testcase component to COMPONENT", metavar="COMPONENT")
parser.add_option("-p", "--product", dest="product",
                  help="set testcase product to PRODUCT", metavar="PRODUCT")
(options, args) = parser.parse_args()
if not options.output_file or\
   not options.author or\
   not options.component or\
   not options.product or\
   not sys.argv[-1]:
    parser.error("incorrect number of arguments")


feature_file = sys.argv[-1]
feature = gherkin_parser.parse_file(feature_file)

with codecs.open(options.output_file, "w", "utf-8") as output:
    # Open XML file and write default header
    root = ET.Element("testopia")
    root.attrib['version']='1.1'

    for scenario in feature.scenarios:
        testcase = ET.SubElement(root, "testcase")
        testcase.attrib['author'] = options.author
        testcase.attrib['priority'] = "P1"
        testcase.attrib['automated'] = ""
        testcase.attrib['status'] = "PROPOSED"

        summary = ET.SubElement(testcase, "summary")
        summary.text = scenario.name

        categoryname = ET.SubElement(testcase, "categoryname")
        categoryname.text = "Function"

        component = ET.SubElement(testcase, "component")
        component.attrib['product'] = options.product
        component.text = options.component

        ET.SubElement(testcase, "defaulttester")
        ET.SubElement(testcase, "notes")

        testplan_reference = ET.SubElement(testcase, "testplan_reference")
        testplan_reference.attrib['type'] = 'Xml_description'
        testplan_reference.text = feature.name

        def append_text_or_table(step_root, step_obj):
            if step_obj.table:
                table = ET.SubElement(step_root, "table")
                table.attrib['border'] = "1"

                heading_tr = ET.SubElement(table, "tr")
                for heading in step_obj.table.headings:
                    heading_td = ET.SubElement(heading_tr, "td")
                    heading_td.text = heading

                for row in step_obj.table.rows:
                    row_tr = ET.SubElement(table, "tr")
                    for cell in row.cells:
                        cell_td = ET.SubElement(row_tr, "td")
                        cell_td.text = cell

            if step_obj.text:
                pre = ET.SubElement(step_root, "pre")
                pre.text = step_obj.text

        setup = ET.SubElement(testcase, "setup")
        if feature.background:
            background_step_list = ET.Element("ul")
            for step_obj in feature.background:
                step_li = ET.SubElement(background_step_list, "li")
                append_text_or_table(step_li, step_obj)
                step_li.text = step_obj.name.strip()
            setup.text = ET.tostring(background_step_list)

        action_step_list = ET.Element("ol")
        effects_step_list = ET.Element("ol")
        breakdown_step_list = ET.Element("ol")

        no_more_actions = False
        # Iterate steps
        for step_obj in scenario.steps:
            if step_obj.keyword == '*':
                # An action? Write it to actions list and set effect to empty
                if not no_more_actions:
                    step_li = ET.SubElement(action_step_list, "li")
                    step_li.text = step_obj.name.strip()
                    append_text_or_table(step_li, step_obj)
                else:
                    step_li = ET.SubElement(breakdown_step_list, "li")
                    step_li.text = step_obj.name.strip()
                    append_text_or_table(step_li, step_obj)
            elif step_obj.keyword == 'Then':
                no_more_actions = True
                step_li = ET.SubElement(effects_step_list, "li")
                step_li.text = step_obj.name.strip()
                append_text_or_table(step_li, step_obj)

        action = ET.SubElement(testcase, "action")
        action.text = ET.tostring(action_step_list)

        effects = ET.SubElement(testcase, "expectedresults")
        effects.text = ET.tostring(effects_step_list)

        breakdown = ET.SubElement(testcase, "breakdown")
        breakdown.text = ET.tostring(breakdown_step_list)

    output.write(ET.tostring(root, encoding="utf-8"))
