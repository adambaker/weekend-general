require "spec_helper"

describe EventsController do
  describe "routing" do
    it "recognizes and generates #index" do
      {get: "/events"}.should route_to(controller: "events", action: "index")
    end

    it "recognizes and generates #new" do
      {get: "/events/new"}.should route_to(controller: "events", action: "new")
    end

    it "recognizes and generates #show" do
      {get: "/events/1"}.should route_to(
        controller: "events", action: "show", id: "1")
    end

    it "recognizes and generates #edit" do
      {get: "/events/1/edit" }.should route_to(
        controller: "events", action: "edit", id: "1")
    end

    it "recognizes and generates #create" do
      {post: "/events"}.should route_to(controller: "events", action: "create")
    end

    it "recognizes and generates #update" do
      {put: "/events/1" }.should route_to(
        controller: "events", action: "update", id: "1")
    end

    it "recognizes and generates #destroy" do
      {delete: "/events/1"}.should route_to(
        controller: "events", action: "destroy", id: "1")
    end
    
    describe "link routes" do    
      it "recognizes and generates #create" do
        {post: '/events/1/links'}.should route_to(
          controller: 'links', action: 'create', event_id: '1')
      end
      
      it "recognizes and generates #update" do
        {put: '/events/1/links/2'}.should route_to(
          controller: 'links', action: 'update', event_id: '1', id: '2')
      end
      
      it "recognizes and generates #destroy" do
        {delete: '/events/1/links/2'}.should route_to(
          controller: 'links', action: 'destroy', event_id: '1', id: '2')
      end
    end
    
    describe "rsvp association routes" do
      it "recognizes and generates #create" do
        {post: '/events/1/rsvps'}.should route_to(
          controller: 'rsvps', action: 'create', event_id: '1')
      end
      
      it "recognizes and generates #destroy" do
        {delete: '/events/1/rsvps/2'}.should route_to(
          controller: 'rsvps', action: 'destroy', event_id: '1', id: '2')
      end
    end
    
    describe "host association routes" do
      it "recognizes and generates #create" do
        {post: '/events/1/hosts'}.should route_to(
          controller: 'rsvps', action: 'create', event_id: '1', kind: 'host')
      end
      
      it "recognizes and generates #destroy" do
        {delete: '/events/1/hosts/2'}.should route_to(
          controller: 'rsvps', action: 'destroy', 
          event_id: '1', id: '2', kind: 'host')
      end
    end
    
    describe "attendee association routes" do
      it "recognizes and generates #create" do
        {post: '/events/1/attendees'}.should route_to(
          controller: 'rsvps', action: 'create', event_id: '1', kind: 'attend')
      end
      
      it "recognizes and generates #destroy" do
        {delete: '/events/1/attendees/2'}.should route_to(
          controller: 'rsvps', action: 'destroy', 
          event_id: '1', id: '2', kind: 'attend')
      end
    end
    
    describe "maybe association routes" do
      it "recognizes and generates #create" do
        {post: '/events/1/maybes'}.should route_to(
          controller: 'rsvps', action: 'create', event_id: '1', kind: 'maybe')
      end
      
      it "recognizes and generates #destroy" do
        {delete: '/events/1/maybes/2'}.should route_to(
          controller: 'rsvps', action: 'destroy', 
          event_id: '1', id: '2', kind: 'maybe')
      end
    end
  end
end
