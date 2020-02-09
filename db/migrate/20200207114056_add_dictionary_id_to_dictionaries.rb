class AddDictionaryIdToDictionaries < ActiveRecord::Migration[5.0]
  def change
    add_column :dictionaries, :dictionary_id, :string, after: :id

    Dictionary.where(dictionary_id: nil).each do |dictionary|
      dictionary.update!(dictionary_id: SecureRandom.hex)
    end

    add_index :dictionaries, :dictionary_id, unique: true
  end
end
