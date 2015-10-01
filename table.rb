class Table < Middleman::Extension
  def initialize(app, options_hash={}, &block)
    super
  end

  helpers do
    def table(&block)
      rows = YAML.load(capture(&block))
      headers = rows.map { |r| r.keys }.flatten.uniq
      new_rows = rows.map do |r|
        headers.map do |h|
          r[h]
        end
      end
      @_out_buf.concat <<-TABLE
        <table>
          <thead>
            <tr>
              #{headers.map {|h| "<th>#{h}</th>"}.join('')}
            </tr>
          </thead>
          <tbody>
            #{new_rows.map {|row| "<tr>#{row.map {|field| "<td>#{field}</td>"}.join('')}</tr>" }.join('')}
          </tbody>
        </table>
      TABLE
    end

    def parameter_table
      @_out_buf.concat  <<-TABLE_TOP
        <table>
          <thead>
            <tr>
              <th>Name</th><th>Description</th><th>Valid Values</th><th>Example Values</th>
            </tr>
          </thead>
          <tbody>
      TABLE_TOP

      yield

      @_out_buf.concat <<-TABLE_BOTTOM
          </tbody>
        </table>
      TABLE_BOTTOM
    end

    ATTRIBUTE_ORDER = [:name, :description, :valid_values, :example_values]
    def parameter(name, attributes)
      attributes[:name] = name
      "<tr class='#{attributes[:deprecated] ? 'deprecated' : ''}'>#{ATTRIBUTE_ORDER.map { |attr| cell_for(attributes[attr]) }.join('')}</tr>"
    end

    def cell_for(value)
      "<td><span>#{process_value value}</span></td>"
    end

    def process_value(value)
      return unless value


      if value.is_a? Array
        "<ul>#{value.map { |v| "<li>#{process_value v}</li>"}.join('')}</ul>"
      else
        value = CGI.escapeHTML(value)
        value.gsub(/\n/, '<br />')
      end
    end
  end
end

::Middleman::Extensions.register(:table, Table)
