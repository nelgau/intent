intent
======

Do only what you intend.

### Usage

You can use Intent to create a cross section of a large codebase.

For example, run the following code.

    Intent.slice do
      fire_the_missiles
    end
    
You will see Intent spring into action:

    [slice] Running...
    [slice] Analyzing trace...
    [slice] Slicing files...
      -> app/models/core/country.rb
      -> app/models/core/city.rb  
      -> lib/missile_guidance.rb
      -> lib/launch_codes.rb
    [slice] Done. :)
  
It will trace the execution of ```fire_the_missiles``` and create a new directory within the project
called ```.slice```. This folder will contain only the methods that were executed during the block,
possibly reducing the breadth of a large codebase down to just a few methods that need to be
considered for inspection.
