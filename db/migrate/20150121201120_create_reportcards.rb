class CreateReportcards < ActiveRecord::Migration
  def change
    create_table :reportcards do |t|

      t.timestamps
    end
  end
end
