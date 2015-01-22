Package.describe({
  name: 'smeevil:reactive-animated-list',
  summary: 'Removal is now fading out',
  version: '1.0.3',
  git: 'https://github.com/smeevil/reactive-animated-list.git'
});

Package.onUse(function(api) {
  api.versionsFrom("METEOR@0.9.0");
  api.use(
      [
        'templating',
        'underscore@1.0.0',
        'coffeescript@1.0.0',
        'mquandalle:jade@0.4.1',
        'fourseven:scss@1.0.0',
      ]
  );

  api.add_files([
          'smeevil_reactive_list.jade',
          'smeevil_reactive_list.coffee',
          'smeevil_reactive_list.sass'
      ], 'client'
  );
});