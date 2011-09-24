importCSVtoCoreData
============================

importCSVtoCoreData is a  tool that import csv file 

importCSVtoCoreData  is licensed under the MIT License.
Please see the LICENSE file for specific details.

Features
--------------------

importCSVtoCoreData suppurts to import a CSV file written with specified format to CoreData.

Requirement
--------------------

- Mac OSX Snow leopard or Lion
- Xcode 4.X

How to use
--------------------

1. Build this project
2. Open the finder that  importCSVtoCoreData binary exists.
3. Copy a momd(CoreData schema definition) directory to the above path.
4. Run the following command on a terminal.app. 

```
importCSVtoCoreData [table-name]_xxxxxx.csv [sqlite-file-name] [xcmodel-name]
```

ex) Import Members_test.csv to importCSVtoCoreData.sqlite with importCSVtoCoreData.momd of xcdatamodel.

<pre></code>
$ ./importCSVtoCoreData Members_test.csv importCSVtoCoreData.sqlite importCSVtoCoreData.momd
EntityName:Members ..
Success!! Saved to 2 contents. 
</code></pre>

This sample is in PROJECT_HOME/Samples.


CSV format
--------------------

- FileName : [table_name]_[tag].csv
- 1st line : Field name with "," separator
- 2nd line : Field type with "," separator
- Over 3rd line : data  with "," separator

You can import following field types in Current version.

- 0 : String type
- 1 : Number type
- 2 : Binary type

This sample is in PROJECT_HOME/Samples.

Thanks
--------------------

importCSVtoCoreData depends on CSVParser class of Matt Gallagher.

http://cocoawithlove.com/2009/11/writing-parser-using-nsscanner-csv.html

Thank!


Getting Help
------------

### Twitter

Please consider following the [@sockspaw Twitter](http://www.twitter.com/sockspaw).
