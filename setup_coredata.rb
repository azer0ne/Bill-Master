require 'xcodeproj'
require 'fileutils'

project_path = 'BillMaster.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Create the model directory
model_name = 'BillMaster.xcdatamodeld'
model_path = File.join('BillMaster', 'Resource', model_name)
version_path = File.join(model_path, 'BillMaster.xcdatamodel')
FileUtils.mkdir_p(version_path)

# Write the contents xml
contents_xml = <<-XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<model type="com.apple.IDECoreDataModeler.DataModel" documentVersion="1.0" lastSavedToolsVersion="1" systemVersion="11A480e" minimumToolsVersion="Xcode 4.3" macosVersion="10.7" iOSVersion="5.0">
    <entity name="CDPaymentMethod" representedClassName="CDPaymentMethod" syncable="YES" codeGenerationType="class">
        <attribute name="id" optional="YES" attributeType="UUID" usesScalarValueType="NO"/>
        <attribute name="name" optional="YES" attributeType="String"/>
        <attribute name="type" optional="YES" attributeType="String"/>
        <relationship name="subscriptions" optional="YES" toMany="YES" deletionRule="Nullify" destinationEntity="CDSubscription" inverseName="paymentMethod" inverseEntity="CDSubscription"/>
    </entity>
    <entity name="CDSubscription" representedClassName="CDSubscription" syncable="YES" codeGenerationType="class">
        <attribute name="amount" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
        <attribute name="categoryValue" optional="YES" attributeType="String"/>
        <attribute name="currency" optional="YES" attributeType="String" defaultValueString="IDR"/>
        <attribute name="frequencyValue" optional="YES" attributeType="String"/>
        <attribute name="id" optional="YES" attributeType="UUID" usesScalarValueType="NO"/>
        <attribute name="name" optional="YES" attributeType="String"/>
        <attribute name="nextBillingDate" optional="YES" attributeType="Date" usesScalarValueType="NO"/>
        <relationship name="paymentMethod" optional="YES" maxCount="1" deletionRule="Nullify" destinationEntity="CDPaymentMethod" inverseName="subscriptions" inverseEntity="CDPaymentMethod"/>
    </entity>
    <elements>
        <element name="CDPaymentMethod" positionX="-90" positionY="0" width="128" height="90"/>
        <element name="CDSubscription" positionX="-90" positionY="0" width="128" height="150"/>
    </elements>
</model>
XML

File.write(File.join(version_path, 'contents'), contents_xml)

# Write the .xccurrentversion
current_version_plist = <<-PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>_XCCurrentVersionName</key>
	<string>BillMaster.xcdatamodel</string>
</dict>
</plist>
PLIST
File.write(File.join(model_path, '.xccurrentversion'), current_version_plist)

# Add to the Xcode project
main_target = project.targets.find { |t| t.name == 'BillMaster' }
resource_group = project.main_group.find_subpath(File.join('BillMaster', 'Resource'), true)

# check if it already exists
unless resource_group.files.any? { |f| f.path == model_name }
  file_ref = resource_group.new_reference(model_name)
  main_target.add_resources([file_ref])
  project.save
  puts "Successfully added #{model_name} to project"
else
  puts "#{model_name} already in project"
end
