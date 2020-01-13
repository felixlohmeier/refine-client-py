#!/usr/bin/env python
"""
test_refine.py

These tests require a connection to a Refine server either at
http://127.0.0.1:3333/ or by specifying environment variables
OPENREFINE_HOST and OPENREFINE_PORT.
"""

# Copyright (c) 2011 Paul Makepeace, Real Programmers. All rights reserved.

import csv
import unittest

from google.refine import refine
import refinetest

from io import StringIO


class RefineServerTest(refinetest.RefineTestCase):
    def test_init(self):
        server_url = 'http://' + refine.REFINE_HOST
        if refine.REFINE_PORT != '80':
            server_url += ':' + refine.REFINE_PORT
        self.assertEqual(self.server.server, server_url)
        self.assertEqual(refine.RefineServer.url(), server_url)
        # strip trailing /
        server = refine.RefineServer('http://refine.example/')
        self.assertEqual(server.server, 'http://refine.example')

    def test_list_projects(self):
        projects = self.refine.list_projects()
        self.assertTrue(isinstance(projects, dict))

    def test_get_version(self):
        version_info = self.server.get_version()
        for item in ('revision', 'version', 'full_version', 'full_name'):
            self.assertTrue(item in version_info)

    def test_version(self):
        self.assertTrue(self.server.version in ('3.2'))


class RefineTest(refinetest.RefineTestCase):
    project_file = 'duplicates.csv'

    def test_new_project(self):
        self.assertTrue(isinstance(self.project, refine.RefineProject))

    def test_wait_until_idle(self):
        self.project.wait_until_idle()  # should just return

    def test_get_models(self):
        self.assertEqual(self.project.key_column, 'email')
        self.assertTrue('email' in self.project.columns)
        self.assertTrue('email' in self.project.column_order)
        self.assertEqual(self.project.column_order['name'], 1)

    def test_delete_project(self):
        self.assertTrue(self.project.delete())

    def test_open_export(self):
        response = refine.RefineProject(self.project.project_url()).export()
        lines = response.text.splitlines()
        self.assertTrue('email' in lines[0])
        for line in lines[1:]:
            self.assertTrue('M' in line or 'F' in line)

    def test_open_export_csv(self):
        response = refine.RefineProject(self.project.project_url()).export()
        csv_fp = csv.reader(StringIO(response.text), dialect='excel-tab')
        row = csv_fp.__next__()
        self.assertTrue(row[0] == 'email')
        for row in csv_fp:
            self.assertTrue(row[3] == 'F' or row[3] == 'M')


if __name__ == '__main__':
    unittest.main()
