object false
node(:length) { @organizations.length }
child @organizations do
  extends 'organizations/_organization'
end
